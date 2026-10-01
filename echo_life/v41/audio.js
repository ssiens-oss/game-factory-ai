/** Small, asset-free synthesizer. Audio begins only after a user gesture. */
export class AudioSystem {
  constructor() {
    this.context = null;
    this.master = null;
    this.muted = false;
    this.voices = new Set();
    this.maxVoices = 16;
    this.noiseBuffer = null;
  }

  async unlock() {
    try {
      if (!this.context) {
        const Context = globalThis.AudioContext || globalThis.webkitAudioContext;
        if (!Context) return false;
        this.context = new Context();
        this.master = this.context.createGain();
        this.master.gain.value = this.muted ? 0 : 0.25;
        const compressor = this.context.createDynamicsCompressor();
        compressor.threshold.value = -12;
        compressor.ratio.value = 6;
        this.master.connect(compressor);
        compressor.connect(this.context.destination);
        this.noiseBuffer = this.context.createBuffer(1, Math.ceil(this.context.sampleRate * 0.22), this.context.sampleRate);
        const channel = this.noiseBuffer.getChannelData(0);
        for (let i = 0; i < channel.length; i++) channel[i] = Math.random() * 2 - 1;
      }
      if (this.context.state === 'suspended') await this.context.resume();
      return this.context.state === 'running';
    } catch { return false; }
  }

  setMuted(value) {
    this.muted = Boolean(value);
    if (this.master) {
      this.master.gain.setTargetAtTime(this.muted ? 0 : 0.25, this.context.currentTime, 0.015);
    }
  }

  track(source, gain, filter = null) {
    while (this.voices.size >= this.maxVoices) {
      const oldest = this.voices.values().next().value;
      try { oldest.stop(); } catch { /* It may already have ended. */ }
      this.voices.delete(oldest);
    }
    this.voices.add(source);
    source.onended = () => {
      this.voices.delete(source);
      source.disconnect();
      gain.disconnect();
      filter?.disconnect();
    };
  }

  tone(frequency, endFrequency, duration, type = 'sine', volume = 0.4, delay = 0) {
    const start = this.context.currentTime + delay;
    const oscillator = this.context.createOscillator();
    const gain = this.context.createGain();
    oscillator.type = type;
    oscillator.frequency.setValueAtTime(frequency, start);
    oscillator.frequency.exponentialRampToValueAtTime(Math.max(20, endFrequency), start + duration);
    gain.gain.setValueAtTime(0.0001, start);
    gain.gain.exponentialRampToValueAtTime(volume, start + 0.004);
    gain.gain.exponentialRampToValueAtTime(0.0001, start + duration);
    oscillator.connect(gain);
    gain.connect(this.master);
    this.track(oscillator, gain);
    oscillator.start(start);
    oscillator.stop(start + duration + 0.01);
  }

  noise(duration, frequency, volume = 0.35) {
    const start = this.context.currentTime;
    const source = this.context.createBufferSource();
    const filter = this.context.createBiquadFilter();
    const gain = this.context.createGain();
    source.buffer = this.noiseBuffer;
    filter.type = 'lowpass';
    filter.frequency.value = frequency;
    gain.gain.setValueAtTime(volume, start);
    gain.gain.exponentialRampToValueAtTime(0.0001, start + duration);
    source.connect(filter);
    filter.connect(gain);
    gain.connect(this.master);
    this.track(source, gain, filter);
    source.start(start);
    source.stop(start + duration);
  }

  play(kind) {
    if (this.muted || !this.context || this.context.state !== 'running') return;
    try {
      switch (kind) {
        case 'shot':
          this.tone(190, 55, 0.09, 'triangle', 0.48);
          this.noise(0.045, 4600, 0.24);
          break;
        case 'hit':
          this.tone(420, 115, 0.07, 'square', 0.15);
          this.noise(0.06, 2100, 0.18);
          break;
        case 'kill':
          this.tone(135, 35, 0.18, 'sawtooth', 0.25);
          this.noise(0.15, 1350, 0.33);
          break;
        case 'dash':
          this.tone(100, 780, 0.13, 'triangle', 0.25);
          this.noise(0.12, 3500, 0.18);
          break;
        case 'reload':
          this.tone(520, 400, 0.05, 'square', 0.1);
          this.tone(730, 560, 0.06, 'square', 0.1, 0.13);
          break;
        case 'hurt':
          this.tone(90, 32, 0.2, 'sawtooth', 0.42);
          this.noise(0.16, 750, 0.24);
          break;
        case 'level':
          [523.25, 659.25, 783.99, 1046.5].forEach((frequency, index) => {
            this.tone(frequency, frequency, 0.2, 'sine', 0.32, index * 0.09);
          });
          break;
      }
    } catch { /* Sound is optional; unavailable audio never interrupts a game. */ }
  }
}

export default AudioSystem;
