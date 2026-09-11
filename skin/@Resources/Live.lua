-- Strict data reader. A snapshot is never a Lua program or a Rainmeter include.
local L={}
local errors={authentication='Prihlásenie zdroja vyžaduje pozornosť',timeout='Zber prekročil časový limit',
  source='Zdroj momentálne nevrátil údaje',invalid_output='Neplatný export zdroja',invalid_quota='Neplatná hodnota kvóty',
  missing_cli='Win-CodexBar CLI nie je dostupný',unsupported_version='Win-CodexBar sa zmenil; treba overiť verziu',
  invalid_config='Chýba platné lokálne nastavenie',rate_limit='Zdroj obmedzil počet požiadaviek',
  invalid_snapshot='Snapshot nie je dostupný alebo je neplatný',adapter_error='Lokálny adaptér nedokončil zber',
  ambiguous_zero='Zdrojovú nulu nemožno spoľahlivo overiť'}
local labels={codex_spark='Codex Spark · 5 h',claude_sonnet='Claude Sonnet · týždeň',claude_opus='Claude Opus · týždeň'}
local function num(value)
  if type(value)~='string' or not value:match('^%d+%.?%d*$') then return nil end
  local n=tonumber(value);if not n or n~=n or n==math.huge then return nil end;return n
end
function L.parse(raw)
  if type(raw)~='string' or #raw>32768 then return nil end
  local t={}
  for line in raw:gmatch('[^\r\n]+') do
    local k,v=line:match('^([a-z0-9_%.]+)=([a-zA-Z0-9_%.:%-]*)$')
    if not k or t[k]~=nil then return nil end;t[k]=v
  end
  if t.schema~='1' or t.mode~='LIVE' then return nil end
  return t
end
function L.read(path)
  local file=io.open(path,'rb');if not file then return nil end
  local raw=file:read(32769);file:close();return L.parse(raw)
end
function L.data(snapshot,M,now,readError)
  local t=snapshot or {};local data={}
  local interval=math.max(180,math.min(3600,num(t.interval) or 180))
  for _,id in ipairs({'codex','claude'}) do
    local function get(key) return t[id..'.'..key] end
    local fetched=num(get('fetched_at'));local sourceAt=num(get('source_at'))
    local status=readError and 'invalid_snapshot' or get('status') or 'waiting'
    local stale=fetched and (now-fetched>math.max(600,interval*2) or fetched>now+60 or
      (id=='claude' and sourceAt and now-sourceAt>math.max(600,interval*2)))
    local failure=status~='ok' and status~='waiting'
    local function quota(prefix)
      local availability=get(prefix..'.availability')
      if availability~='present' and availability~='absent' then availability='unknown' end
      local used=num(get(prefix..'.used'));if used and used>100 then used=nil end
      -- Also protect a snapshot created before the adapter gained this guard.
      if used==0 and (id=='codex' or get('source')=='web') then used=nil;availability='unknown' end
      local received=num(get(prefix..'.received_at'))
      local q=M.quota({availability=availability,used=used,reset_at=num(get(prefix..'.reset_at')),
        observed_at=id=='claude' and sourceAt or nil,
        quality=(failure or get(prefix..'.quality')=='error') and 'error' or stale and 'stale' or id=='codex' and 'unknown' or 'fresh'})
      q.live=true;q.provider=id;q.fetched_at=fetched;q.source_at=sourceAt;q.received_at=received
      q.transport_stale=stale;q.source_status=status
      if q.availability=='present' and q.reset_at and q.reset_at<=now then q.quality='stale' end
      return q
    end
    local p={weekly=quota('weekly'),session=quota('session'),extras={},status=status,
      identity_known=get('identity')~=nil and get('identity')~='unknown',
      fetched_at=fetched,source=get('source'),next_at=num(get('next_at'))}
    p.error=errors[status]
    if status=='waiting' then p.error='Čaká na prvý export Win-CodexBaru' end
    if not snapshot then p.error='Snapshot ešte nie je dostupný alebo je neplatný' end
    for i=1,math.min(3,num(get('extra_count')) or 0) do
      local code=get('extra.'..i..'.code')
      if labels[code] then
        local q=quota('extra.'..i)
        if q.availability=='present' then p.extras[#p.extras+1]={title=labels[code],quota=q} end
      end
    end
    p.omitted=num(get('extra_omitted')) or 0
    data[id]=p
  end
  return data
end
function L.freshness(q,now)
  if not q.fetched_at then return 'Údaj zatiaľ nebol získaný' end
  local age=math.max(0,math.floor((now-q.fetched_at)/60))
  if q.source_status~='ok' or q.transport_stale or q.quality=='error' then
    local goodAge=math.max(0,math.floor((now-(q.received_at or q.fetched_at))/60))
    return 'Posledný platný export pred '..goodAge..' min · neaktuálne'
  end
  if q.provider=='codex' then return 'Export pred '..age..' min · vek kvóty neznámy' end
  if not q.source_at then return 'Export pred '..age..' min · čas zdroja neznámy' end
  return 'Zber zdroja pred '..math.max(0,math.floor((now-q.source_at)/60))..' min'
end
return L
