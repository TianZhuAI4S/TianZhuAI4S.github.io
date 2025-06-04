---
title:          "Accurate structure prediction of immune proteins using parameter-efficient transfer learning"
date:           2024-11-15 00:01:00 +0800
selected:       true
pub:            "BioRxiv"
# pub_pre:        "Submitted to "
# pub_post:       'Under review.'
# pub_last:       ' <span class="badge badge-pill badge-publication badge-success">Spotlight</span>'
pub_date:       "2024"

abstract: >-
  We propose ImmuneFold, a transfer learning approach that fine-tunes ESMFold specifically for immune proteins. We leverage low-rank adaption (LoRA), a parameter-efficient fine-tuning technique that requires considerably less memory and substantially fewer parameters. Evaluations on various immune proteins, including T-cell receptors, antibodies, and nanobodies, demonstrate that ImmuneFold outperforms existing methods in prediction accuracy. Furthermore, we apply ImmuneFold to develop a zero-shot protocol for TCR-epitope binding prediction. Unlike previous supervised methods suffering from severe overfitting due to limited experimental binding data, our approach first predicts TCR-epitope structure using ImmuneFold and then directly estimates the binding affinity by calculating Rosseta energy.
cover:          /assets/images/covers/ImmuneFold.png
authors:
  - Tian Zhu*
  - Milong Ren*
  - Zaikai He
  - Siyuan Tao
  - Ming Li
  - Dongbo Bu
  - Haicang Zhang
links:
  paper: https://www.biorxiv.org/content/10.1101/2024.11.13.621715v1
  code: https://github.com/CarbonMatrixLab/immunefold
---
