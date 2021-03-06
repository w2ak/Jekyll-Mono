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

  At the MAC level, channels are either dedicated (to one UE) or shared (with every UE).
  In LTE there is no dedicated channel at the physical and transport level.

  Regarding logical channels, dedicated channels (i.e. with [RRC][rrc] connection) are
  [DCCH][dcch] and [DTCH][dtch].  Common channel (no [RRC][rrc] connection) is [CCCH][ccch].

  * How does a UE acquire the physical cell identity?

  The [PCI][pci] is divided in 3 groups of 168 possibilities. The [SSS][sss] broadcasts
  a sequence among 3 and the [PSS][pss] broadcasts a pseudo-random sequence among 168
  possibilities ([page 48](/share/acn/906/03-lte-phy-mac-rlc.pdf#page=48)).

  * How does a UE learn the signal bandwidth?

  The bandwidth is included in the [PBCH][pbch] whose position does not depend on the
  bandwidth.

  * How many OFDM symbols are occupied by PDCCH?

  [PDCCH][pdcch] uses ([page 46](/share/acn/906/03-lte-phy-mac-rlc.pdf#page=46)) between
  1 and 3 [OFDM][ofdm] symbols.

  * How is a UE informed of this number?

  This number of symbols is signaled by the [PCFICH][pcfich].

  * On which physical channel is done resource allocation?

  Resource allocation is done on the [PDCCH][pdcch] with [DCI][dci] messages.

  * What is the difference between PUSCH and PUCCH?

  Both [PUSCH][pusch] and [PUCCH][pucch] are used to carry [UCI][uci], but
  [PUSCH][pusch] is only used if the UE has also application data or [RRC][rrc]
  signaling.

  * What is the difference between DMRS and SRS?

  Both are used for radio quality measurements. [DMRS][dmrs] is used to help demodulating
  the signal transmitted by one UE, while [SRS][srs] is used to measure quality
  on a larger bandwidth.

  * What is the advantage of frequency hopping on PDSCH and PUSCH?

  Diversity gain.

  * On which transport channels are transmitted System Informations?

  System Informations are the MIB and SIBs. The [MIB][mib] is transported by [BCH][pbch]
  the [SIBs][sib] are all transported on the [DL-SCH][pdsch]. The first SIB contains the
  scheduling of the other SIBs, and its own location is given by the [PDCCH][pdcch].

  * What type of information is carried by DCIs?

  [DCIs][dci] (on the [PDCCH][pdcch]) carry the location of the first [SIB][sib] in
  the [PDSCH][pdsch] and other resource allocation information.

  * Which DCI is used for resource allocation on the UL?

  DCI0

  * On which physical channel are UCI transmitted?

  PUCCH and PUSCH

  * On which logical channels are signaling message transmitted when the UE has no RRC connection? When it has a RRC connection?

  with: DCCH. without: CCCH

## MAC/RLC sublayers

  * In which layers are located HARQ and ARQ functions?

  HARQ is on the MAC layer, ARQ is on the RLC layer.

  * What are the RLC modes?

  Acknowledged Mode, Transparent Mode, Unacknowledged Mode

  * Give one function of PDCP.

  IP Header compression, security, handover function

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
[rrc]: /404
[dcch]: /404
[dtch]: /404
[ccch]: /404
[pci]: /404
[sss]: /404
[pss]: /404
[pbch]: /404
[pdcch]: /404
[pdsch]: /404
[pcfich]: /404
[prach]: /404
[pusch]: /404
[pucch]: /404
[uci]: /404
[dmrs]: /404
[srs]: /404
[mib]: /404
[sib]: /404
