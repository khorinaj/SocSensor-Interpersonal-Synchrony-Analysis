

function yscramble = phase_scramble(yin)

yft = fft(yin);

rphase = angle(fft(rand(size(yft))));

amp = abs(yft);
phase = angle(yft);
% new_phase = phase + rphase;
new_phase = phase(randperm(numel(phase))) ;
% ensure offset donnot change
new_phase(1)=phase(1);
yscramble = ifft(amp.*exp(sqrt(-1)*(new_phase)));

yscramble = real(yscramble);
end