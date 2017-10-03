---
layout: post
toc: false
author: Clément Durand
date: 2017-10-02
permalink: /acn/lte-air-interface.html

---

# Exercise 1

*Questions on PHY, MAC and RLC layers of LTE.*

## PHY Layer

  * What are the transmission and multiplexing techniques in DL and UL?
  * What are the modulations in DL and UL?
  * What is the duplexing scheme?
  * What are the main spectrum bands used in 4G in France?
  * What are the advantages and drawbacks of OFDM?
  * Why is it important to reduce the PAPR on the UL?
  * What is the subcarrier bandwidth?
  * What is a single frequency network?
  * What are the typical MIMO configurations?
  * What are the potential gains in MIMO?
  * What is the difference between open loop and closed loop schemes?
  * What are the advantages and drawbacks of beamforming?
  * Describe the FDD radio frame structure with normal prefix.
  * What is a RE? a RB?

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
