-- Internal DEMO contract; it does not describe a provider API.
local M = {}
local function finite(n) return type(n)=='number' and n==n and n~=math.huge and n~=-math.huge end
local function copy(t) local c={} for k,v in pairs(t or {}) do c[k]=v end return c end
function M.quota(raw, previous)
  raw = type(raw)=='table' and raw or {}
  local q={availability=raw.availability, quality=raw.quality or 'unknown'}
  if q.availability=='absent' then q.quality='fresh'; return q end
  if q.availability~='present' and q.availability~='unknown' then q.availability='unknown' end
  local valid=finite(raw.used) and raw.used>=0 and raw.used<=100
  if q.availability=='present' and valid then
    q.used=raw.used
    q.reset_at=finite(raw.reset_at) and raw.reset_at or nil
    q.observed_at=finite(raw.observed_at) and raw.observed_at or nil
    if q.quality~='fresh' and q.quality~='stale' and q.quality~='error' then q.quality='unknown' end
    if not q.observed_at and q.quality=='fresh' then q.quality='unknown' end
  elseif previous and finite(previous.used) and previous.availability=='present' then
    q=copy(previous); q.quality=raw.quality=='error' and 'error' or 'stale'
    q.availability_uncertain=raw.availability~='present'
  else q.availability='unknown'; q.quality='unknown' end
  return q
end
function M.percent(q)
  if not q or not finite(q.used) then return '—' end
  return string.format('%g%%',q.used)
end
function M.arc(q)
  local present=q and q.availability=='present' and finite(q.used)
  local used=present and q.used or 0
  return {track=present, used=used, degrees=used*3.6, caps=present and used>0 and used<100,
          end_angle=-math.pi/2+used/100*2*math.pi}
end
function M.countdown(q, now)
  if not q or not q.reset_at then return 'Čas resetu nie je známy' end
  local delta=math.ceil(q.reset_at-now)
  if delta<=0 then return 'Čaká na nový údaj po resete' end
  local days=math.floor(delta/86400); delta=delta%86400
  local hours=math.floor(delta/3600); delta=delta%3600
  local minutes=math.floor(delta/60)
  if days>0 then return string.format('Obnova za %d d %02d h %02d min',days,hours,minutes) end
  return string.format('Obnova za %02d:%02d:%02d',hours,minutes,delta%60)
end
function M.freshness(q, now)
  if not q or q.availability=='unknown' and not q.used then return 'Údaj / dostupnosť neoverené' end
  local prefix=({fresh='DEMO údaj',stale='Neaktuálne',error='TEST chyba · posledný údaj',unknown='Čerstvosť neistá'})[q.quality] or 'Čerstvosť neistá'
  if not q.observed_at then return prefix..' · vek neznámy' end
  local minutes=math.max(0,math.floor((now-q.observed_at)/60))
  if minutes==0 then return prefix..' · pred menej ako minútou' end
  return prefix..' · pred '..minutes..' min'
end
-- The ring anchor stays fixed when detail changes side/height. If neither side
-- fits at the requested scale, compact only the detail to the larger free area.
function M.layout(anchor, base_height, desired, work_top, work_height)
  if desired<=0 then return {offset=0,height=base_height,detail_y=0,ratio=1,above=false} end
  local below=math.max(0,work_top+work_height-anchor-base_height)
  local above=math.max(0,anchor-work_top)
  local use_above=desired>below and (desired<=above or above>below)
  local space=use_above and above or below
  local actual=math.min(desired,space)
  return {offset=use_above and actual or 0,height=base_height+actual,
    detail_y=use_above and 0 or base_height,ratio=actual/desired,above=use_above}
end
function M.event_state() return {seen={}, acknowledged={}, active=nil, announcements=0} end
function M.receive_event(state,event)
  if not event or not event.event_id or state.seen[event.event_id] then return false end
  state.seen[event.event_id]=true;state.active=event;state.announcements=state.announcements+1
  return true
end
function M.acknowledge(state)
  if state.active then state.acknowledged[state.active.event_id]=true;state.active=nil end
end
return M
