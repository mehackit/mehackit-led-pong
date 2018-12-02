osc_adress = "/osc:127.0.0.1:50523/"
MUSIC_ON = false

use_bpm 120
note = :c
IDLE = 0
GAME_START = 1
GAME_ON = 2
GAME_OVER = 3
state = IDLE
chrd = (chord_degree :i, :c, :major, 4, invert: 1, num_octaves: 2)

live_loop :osc do
  use_real_time
  osc = sync osc_adress + "state"
  state = osc[0]
end

live_loop :note do
  if (state == GAME_ON)
    note = (ring :c, :c, :a).tick
  end
  sleep 4
end

live_loop :arp do
  use_synth :tb303
  if (state == GAME_ON and MUSIC_ON)
    with_octave -1 do
      play chrd.tick, release: rrand(0.2, 0.25), cutoff: rrand(60, 85), amp: 0.2, attack: 0.01, env_curve: 1, res: rrand(0.7, 0.9)
    end
  end
  sleep 0.25
end

live_loop :c_bass do
  if (state == GAME_ON and MUSIC_ON)
    use_synth :mod_pulse
    #use_synth_defaults amp: 1, mod_range: 15, cutoff: 80, pulse_width: 0.2, attack: 0.03, release: 0.4,  mod_phase: 0.25, mod_invert_wave: 1
    with_octave [-2, -2, -1].choose do
      play note, release: rrand(0.4, 1), cutoff: rrand(80, 90), amp: 1.3, pulse_width: 0.25, mod_phase: 0.25, mod_range: 7 if not one_in(16)
    end
  end
  sleep 0.5
end

live_loop :hit do
  use_real_time
  
  use_synth :chiplead
  
  osc = sync osc_adress + "hit"
  num_notes = osc[0]
  
  degrees = (ring 1, 3, 6, 4)
  inverts = (range -3, 3)
  
  print (num_notes-1)/6
  print num_notes-1
  d = degrees[(num_notes-1)/6]
  i = inverts[num_notes-1]
  
  chrd = (chord_degree d, :c, :major, 4, invert: i, num_octaves: 2)
  
  play_chord (chord_degree d, :c, :major, 3, invert: i), amp: 4
end

live_loop :fx_spawn do
  use_real_time
  osc = sync osc_adress + "spawn"
  sample :bass_voxy_hit_c, amp: 2
end

live_loop :fx_break do
  use_real_time
  osc = sync osc_adress + "break"
  sample :elec_twip, amp: 2
end

live_loop :explode do
  use_real_time
  osc = sync osc_adress + "explode"
  with_fx :distortion, distort: 0.9 do
    with_fx :lpf, cutoff: 90 do
      sample :ambi_lunar_land, rate: 1.5, amp: 2, release: 4, attack: 0.2
    end
  end
end

live_loop :score do
  use_real_time
  osc = sync osc_adress + "score"
  n = osc[0]
  s = (scale :c3, :major, num_octaves: 5)
  play s[n]
end

live_loop :highscore do
  use_real_time
  osc = sync osc_adress + "highscore"
  tick_reset
  12.times do
    play (chord :c, :major).tick
    sleep 0.25
  end
  play :c5
  sleep 4
end

live_loop :go do
  use_real_time
  osc = sync osc_adress + "go"
  sample :elec_pop, amp: 2
end

live_loop :start do
  use_real_time
  osc = sync osc_adress + "start_sweep"
  
  p = play 48, note_slide: 2, release: 2, attack: 0
  control p, note: 48 + 12
  sleep 1
  sample :elec_blip
end

