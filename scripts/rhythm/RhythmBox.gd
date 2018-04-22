extends Node2D

signal missed_beat
signal succeed_beat
signal quit_guitar

onready var Chords = $Sprite/Chords
onready var Chord0 = $Sprite/Chords/Chord0
onready var Chord1 = $Sprite/Chords/Chord1
onready var Chord2 = $Sprite/Chords/Chord2

var active = false

func _ready():
	connect("missed_beat", self, "_on_missed_beat")

func _input(event):
	if not active: return
	
	if Input.is_action_just_pressed("play_chord_0"):
		Chord0.get_node("Pressed").show()
		check_chord(Chord0)
	
	elif Input.is_action_just_released("play_chord_0"):
		Chord0.get_node("Pressed").hide()
	
	if Input.is_action_just_pressed("play_chord_1"):
		Chord1.get_node("Pressed").show()
		check_chord(Chord1)
	elif Input.is_action_just_released("play_chord_1"):
		Chord1.get_node("Pressed").hide()
	
	if Input.is_action_just_pressed("play_chord_2"):
		Chord2.get_node("Pressed").show()
		check_chord(Chord2)
	elif Input.is_action_just_released("play_chord_2"):
		Chord2.get_node("Pressed").hide()
	
	if Input.is_action_just_pressed("quit_guitar"):
		stop_playing()

func _on_missed_beat():
	$AnimationPlayer.play("missed_beat")

### Beats exited

func _chord0_beat_exited(beat):
	beat_exited(beat)

func _chord1_beat_exited(beat):
	beat_exited(beat)

func _chord2_beat_exited(beat):
	beat_exited(beat)

func beat_exited(beat):
	if not beat.pressed:
		Chords.get_node("MissedChordBeat").play()
		emit_signal("missed_beat")
	beat.queue_free()

###

func playing():
	active = true
	$Music.play()
	connect_chords()
	for beat_spawner in $Sprite/Beats.get_children():
		beat_spawner.start()

func stop_playing():
	active = false
	$Music.stop()
	disconnect_chords()
	for beat_spawner in $Sprite/Beats.get_children():
		beat_spawner.stop()
	emit_signal("quit_guitar")

### Check chord if beat on it

func check_chord(chord):
	if (has_beat_on(chord)):
		Chords.get_node("HitChordBeat").play()
		var beat = chord.get_overlapping_bodies()[0]
		beat.pressed = true
		beat.hide()
		emit_signal("succeed_beat")
	else:
		Chords.get_node("NoHitChord").play()

func has_beat_on(area):
	return area.get_overlapping_bodies().size() == 1

### Connect chords beat

func connect_chords():
	Chord0.connect("body_exited", self, "_chord0_beat_exited")
	Chord1.connect("body_exited", self, "_chord1_beat_exited")
	Chord2.connect("body_exited", self, "_chord2_beat_exited")

func disconnect_chords():
	Chord0.disconnect("body_exited", self, "_chord0_beat_exited")
	Chord1.disconnect("body_exited", self, "_chord1_beat_exited")
	Chord2.disconnect("body_exited", self, "_chord2_beat_exited")