---
title:          "Antibody Design Using a Score-based Diffusion Model Guided by Evolutionary, Physical and Geometric Constraints"
date:           2024-05-12 00:01:00 +0800
selected:       true
pub:            "International Conference on Machine Learning (ICML)"
# pub_pre:        "Submitted to "
# pub_post:       'Under review.'
# pub_last:       ' <span class="badge badge-pill badge-publication badge-success">Spotlight</span>'
pub_date:       "2024"

abstract: >-
  We present AbX, a new score-based diffusion generative model guided by evolutionary, physical, and geometric constraints for antibody design. These constraints serve to narrow the search space and provide priors for plausible antibody sequences and structures. Specifically, we leverage a pre-trained protein language model as priors for evolutionary plausible antibodies and introduce additional training objectives for geometric and physical constraints like van der Waals forces. Furthermore, as far as we know, AbX is the first score-based diffusion model with continuous timesteps for antibody design, jointly modeling the discrete sequence space and the $SE(3)$ structure space.
cover:          /assets/images/covers/AbX.png
authors:
  - Tian Zhu
  - Milong Ren
  - Haicang Zhang
links:
  paper: https://icml.cc/virtual/2024/poster/35143
  Code: https://github.com/CarbonMatrixLab/AbX
---
