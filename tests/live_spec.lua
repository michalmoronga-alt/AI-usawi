return function(M,L)
  local passed=0
  local function check(value,name) assert(value,name);passed=passed+1 end
  check(L.parse('schema=1\nmode=LIVE\n')~=nil,'Minimal valid snapshot')
  check(L.parse('schema=1\nmode=DEMO\n')==nil,'Explicit mode required')
  check(L.parse('schema=1\nmode=LIVE\nschema=1\n')==nil,'Duplicate key rejected')
  check(L.parse('schema=1\nmode=LIVE\ncodex.weekly.used=[!Execute danger]\n')==nil,'Bang injection rejected')
  check(L.parse('return {used=0}')==nil,'Lua source rejected')
  check(L.parse(string.rep('a',32769))==nil,'Oversized snapshot rejected')
  local t={schema='1',mode='LIVE',interval='180'}
  for _,id in ipairs({'codex','claude'}) do
    t[id..'.status']='ok';t[id..'.fetched_at']='1000';t[id..'.source_at']='1000'
    t[id..'.weekly.availability']='present';t[id..'.weekly.used']='42'
    t[id..'.weekly.received_at']='1000';t[id..'.weekly.reset_at']='2000'
    t[id..'.session.availability']='absent'
  end
  local d=L.data(t,M,1100)
  check(d.codex.weekly.used==42 and d.codex.weekly.quality=='unknown','Codex freshness not invented')
  check(d.codex.session.availability=='absent','No invented Codex 5h')
  check(d.claude.weekly.quality=='fresh','Successful Claude capture accepted')
  check(L.freshness(d.codex.weekly,1100):find('vek kvóty neznámy',1,true),'Codex age disclosure')
  t['claude.status']='authentication';d=L.data(t,M,1100)
  check(d.claude.weekly.used==42 and d.claude.weekly.quality=='error','Provider auth retains value as error')
  check(d.codex.status=='ok','Other provider unaffected')
  for _,value in ipairs({'0','100'}) do
    t['claude.weekly.used']=value;d=L.data(t,M,1100)
    check(d.claude.weekly.used==tonumber(value),'Verified boundary '..value)
  end
  t['claude.weekly.used']='42';t['codex.weekly.used']='0';d=L.data(t,M,1100)
  check(M.percent(d.codex.weekly)=='—','Old ambiguous zero snapshot fails closed')
  for _,value in ipairs({'null','nan','-1','101','true'}) do
    t['codex.weekly.used']=value;d=L.data(t,M,1100)
    check(M.percent(d.codex.weekly)=='—','Invalid value '..value)
  end
  t['codex.weekly.used']='42';d=L.data(t,M,2100)
  check(d.codex.weekly.used==42 and d.codex.weekly.quality=='stale','Crossing reset does not zero')
  check(M.countdown(d.codex.weekly,2100)=='Čaká na nový údaj po resete','Expired reset waits for source')
  t['codex.weekly.reset_at']=nil;d=L.data(t,M,1100)
  check(d.codex.weekly.reset_at==nil,'Missing reset remains unknown')
  t['codex.weekly.availability']='absent';t['codex.session.availability']='present';t['codex.session.used']='65'
  d=L.data(t,M,1100)
  check(M.percent(d.codex.weekly)=='—' and d.codex.session.used==65,'Session never substitutes weekly')
  t['claude.status']='ok';t['claude.source_at']='100';d=L.data(t,M,1100)
  check(d.claude.weekly.quality=='stale','Old source timestamp remains stale after new export')
  d=L.data(t,M,1100,true)
  check(d.claude.weekly.used==42 and d.claude.weekly.quality=='error','Invalid snapshot preserves memory with explicit error')
  d=L.data(nil,M,1100)
  check(M.percent(d.codex.weekly)=='—' and d.codex.error~=nil,'No snapshot cannot become demo')
  return 'LIVE Lua: '..passed..' PASS, 0 FAIL\n'
end
