---
layout: post
toc: false
title: LTE TD. PHY, MAC and RLC layers.
author: Clément Durand
date: 2017-10-02
permalink: /acn/lte-air-interface.html
back: /acn/

---

# Exercise 1

*Questions on PHY, MAC and RLC layers of LTE.*

## PHY Layer

  * What are the transmission and multiplexing techniques in DL and UL?

  [OFDMA][ofdma] (for DownLink) and [SC-FDMA][scfdma] (for UpLink) are used as
  multiplexing techniques
  (see [page 18](/share/acn/906/03-lte-phy-mac-rlc.pdf#page=18)).

  [OFDM][ofdm] ([page 20](/share/acn/906/03-lte-phy-mac-rlc.pdf#page=20)):
  Orthogonal Frequency Division Multiplexing

  * What are the modulations in DL and UL?

  Used modulations are [BPSK][bpsk] (Bi Phase Shift Key), [QPSK][qpsk]
  (Quadri Phase Shift Key), [16-QAM][16qam] (Quadrature Amplitude Modulation)
  and [64-QAM][64qam].

  For DownLink, [64-QAM][64qam] is required on any terminal by LTE. For UpLink,
  [64-QAM][64qam] is available only on cat5 terminals.

  * What is the duplexing scheme?

  Possible duplexing schemes are [TDD][tdd] (Time Division Duplexing) and
  [FDD][fdd] (Frequency Division Duplexing).

  * What are the main spectrum bands used in 4G in France?

  `800, 1800, 2600 MHz`
  ([page 19](/share/acn/906/03-lte-phy-mac-rlc.pdf#page=19))

  * What are the advantages and drawbacks of OFDM?

  OFDM reduces multi-path propagation issues
  ([page 20](/share/acn/906/03-lte-phy-mac-rlc.pdf#page=20)):
  [ISI][isi] (Inter Symbol Interference) is almost completely removed. Since the
  orthogonality allows overlaps, it also provides a higher spectral efficiency.

  On the other side, it creates inter-carrier interference
  ([page 26](/share/acn/906/03-lte-phy-mac-rlc.pdf#page=26)) and a high
  [PAPR][papr] (Peak to Average Power Ratio)

  * Why is it important to reduce the PAPR on the UL?

  A high [PAPR][papr] on the UL requires terminals to transmit at a high power
  to allow amplificators to read the signal. Terminals cannot transmit with
  higher powers which is why the [PAPR][papr] should be reduced.

  * What is the subcarrier bandwidth?

  The sub-carrier bandwidth is `15kHz`
  ([page 30](/share/acn/906/03-lte-phy-mac-rlc.pdf#page=30)).

  The carrier bandwidth can be `1.4`, `3`, `5`, `10`, `15` or `20MHz`.

  * What is a single frequency network?

  On a [SFN][sfn] (Single Frequency Network), every cell uses the same
  frequency.

  * What are the typical MIMO configurations?

  Typical [MIMO][mimo] configurations are `2x2`, `2x4`, `4x4`, i.e., 2 or 4
  transmitters and receivers
  ([page 19](/share/acn/906/03-lte-phy-mac-rlc.pdf#page=30)).

  * What are the potential gains in MIMO?

  Potential gains ([page 33](/share/acn/906/03-lte-phy-mac-rlc.pdf#page=33)) are
  a diversity gain (multiple copies implies more robustness), an array gain
  ([beamforming][beamforming] on transmission side, and better [SNR][snr] on
  reception side), and a multiplexing gain.

  * What is the difference between open loop and closed loop schemes?

  In closed loop schemes, the reverse link is used to give feedback to the
  transmitter and improve the flow by adjusting parameters.

  * What are the advantages and drawbacks of beamforming?

  [Beamforming][beamforming] improves the useful signal power but requires
  UE-specific pilot signals.

  * Describe the FDD radio frame structure with normal prefix.

  One frame is `Tf=307200Ts=10ms` long and contains `10` subframes of `2` slots
  of `0.5ms`.

  Each slot contains `7` [OFDMA][ofdma]/[SC-FDMA][scfdma] symbols with their
  prefix. The prefix is `160Ts` long and the next ones are `144Ts` long.

  * What is a RE? a RB?

  One resource block is `7` [OFDMA][ofdma]/[SC-FDMA][scfdma] symbol by `12`
  sub-carriers of `15kHz`, i.e., `7x12` resource elements.

## Physical, transport and logical channels

  * Are there dedicated channels in LTE?
  * How does a UE acquire the physical cell identity?
  * How does a UE learn the signal bandwidth?
  * How many OFDM symbols are occupied by PDCCH?
  * How is a UE informedof this number?
  * On which physical channel is done resource allocation?
  * What is the difference between PUSCH and PUCCH?
  * What is the difference between DMRS and SRS?
  * What is the advantage of frequency hopping on PDSCH and PUSCH?
  * On which transport channels are transmitted System Informations?
  * What type of information is carried by DCIs?
  * Which DCI is used for resource allocation on the UL?
  * On which physical channel are UCI transmitted?
  * On which logical channels are signaling message transmitted when the UE has no RRC connection? When it has a RRC connection?

## MAC/RLC sublayers

  * In which layers are located HARQ and ARQ functions?
  * What are the RLC modes?
  * Give one function of PDCP.

# Exercise 2

*Channels for the outgoing call.*

Indicate on figures 1 and 2 the physical, transport and logical channel used.

# Exercise 3

*Peak data rates in LTE*

  * What is the largest signal bandwidth? What is the corresponding number of RBs?
  * We assume a normal prefix. How many OFDM symbols are there per slot? Per radio frame? Deduce the number of REs per radio frame.
  * What is the minimum number of REs used by PDCCH, PCFICH and PHICH?
  * How many REs are used by SSS, PSS and PBCH?
  * Give an estimation of the protocol overhead due to RSs for a 4 antenna transmission.
  * What is the denser modulation in LTE? What is the maximum number of MIMO parallel flows? What is the duration of a radio frame? Deduce the raw peak data rate.
  * We assume a coding rate of `3/4`. Deduce the peak data rate in DL.
  * Discuss the validity of the preceding result.

[lecture]: /share/acn/906/03-lte-phy-mac-rlc.pdf
[ofdma]: https://en.wikipedia.org/wiki/Orthogonal_frequency-division_multiple_access
[scfdma]: https://en.wikipedia.org/wiki/Single-carrier_FDMA
[ofdm]: https://en.wikipedia.org/wiki/Orthogonal_frequency-division_multiplexing
[bpsk]: https://en.wikipedia.org/wiki/Phase-shift_keying#Binary_phase-shift_keying_.28BPSK.29
[qpsk]: https://en.wikipedia.org/wiki/Phase-shift_keying#Quadrature_phase-shift_keying_.28QPSK.29
[16qam]: https://en.wikipedia.org/wiki/Quadrature_amplitude_modulation#Quantized_QAM
[64qam]: https://en.wikipedia.org/wiki/Quadrature_amplitude_modulation#Quantized_QAM
[tdd]: https://en.wikipedia.org/wiki/Duplex_(telecommunications)#Time-division_duplexing
[fdd]: https://en.wikipedia.org/wiki/Duplex_(telecommunications)#Frequency-division_duplexing
[isi]: https://en.wikipedia.org/wiki/Intersymbol_interference
[papr]: https://en.wikipedia.org/wiki/Crest_factor
[sfn]: https://en.wikipedia.org/wiki/Single-frequency_network
[mimo]: https://en.wikipedia.org/wiki/MIMO
[beamforming]: https://en.wikipedia.org/wiki/Beamforming
[snr]: https://en.wikipedia.org/wiki/Signal-to-noise_ratio
