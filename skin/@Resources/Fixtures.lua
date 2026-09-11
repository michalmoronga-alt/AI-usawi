-- Trusted synthetic fixtures. All times are anchored by build(), not by render().
local F={}
F.order={'normal','codex5h','codex5hzero','zero','quarter','half','full','weeklyMissing','stale','unknown5h','resetUnknown','resetDue','event','invalid'}
F.names={normal='Bežný stav',codex5h='Codex má aj 5h',codex5hzero='Codex 5h: platná nula',zero='Geometria · 0 %',quarter='Geometria · 25 %',half='Geometria · 50 %',full='Geometria · 100 %',weeklyMissing='Weekly chýba, 5h existuje',stale='Staré údaje / chyba služby',unknown5h='Dostupnosť 5h je neistá',resetUnknown='Neznámy / uplynutý reset',resetDue='Reset o 5 sekúnd',event='Nová TEST udalosť',invalid='Neplatný syntetický vstup'}
function F.build(key, now, serial)
  assert(F.names[key], 'Unknown DEMO scenario')
  local function q(used, seconds, quality, age)
    return {availability='present',used=used,reset_at=seconds and now+seconds or nil,
      quality=quality or 'fresh',observed_at=now-(age or 0)}
  end
  local d={id=key,anchor=now,codex={weekly=q(65,187200),session={availability='absent'}},
    claude={weekly=q(42,270000),session=q(65,4320)}}
  if key=='codex5h' then d.codex.session=q(35,6000);d.claude.session=q(0,7200)
  elseif key=='codex5hzero' then d.codex.session=q(0,7200)
  elseif key=='zero' or key=='quarter' or key=='half' or key=='full' then
    local p=({zero=0,quarter=25,half=50,full=100})[key]
    for _,id in ipairs({'codex','claude'}) do d[id].weekly=q(p,172800);d[id].session=q(p,3600) end
  elseif key=='weeklyMissing' then d.codex.weekly={availability='unknown'};d.codex.session=q(65,3600)
  elseif key=='stale' then
    d.codex.weekly=q(65,172800,'stale',7200);d.codex.session=q(35,3600,'stale',7200)
    d.claude.weekly=q(42,259200,'error',5400);d.claude.session=q(65,2400,'error',5400)
    d.claude.error='Simulovaný výpadok služby. Posledné hodnoty zostali.'
  elseif key=='unknown5h' then d.codex.session={availability='unknown'};d.claude.session={availability='unknown'}
  elseif key=='resetUnknown' then d.codex.weekly=q(65,nil);d.claude.weekly=q(42,-120);d.claude.session=q(65,nil)
  elseif key=='resetDue' then d.codex.weekly=q(65,5);d.claude.weekly=q(42,5)
  elseif key=='event' then d.event={event_id='demo-'..now..'-'..serial,provider='codex',title='Nová syntetická udalosť',body='TEST interakcie. Toto nie je detekcia skutočného resetu.'}
  elseif key=='invalid' then d.codex.weekly=q('bad',nil);d.codex.session=q(-4,3600);d.claude.weekly=q(101,3600);d.claude.session={availability='unknown'} end
  return d
end
return F
