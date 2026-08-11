# Interest Rate Derivatives & LMM/BMM Pricing Engine

## Project Overview
This repository contains a MATLAB-based quantitative framework for pricing and hedging complex interest rate derivatives. The engine implements both the LIBOR Market Model (LMM) and the Bond Market Model (BMM) to value structured bonds and path-dependent exotic caps, complete with advanced risk management (Delta/Vega bucket hedging) and volatility smile corrections.

*Note: This was a collaborative academic project developed for the Financial Engineering course at Politecnico di Milano. I took the technical lead on the LIBOR Market Model calibration, structured bond pricing, and the bucket hedging engine (Module 1), while co-developing the BMM Monte Carlo architecture with my team.*

## My Core Contributions: Pricing & Hedging Engine (LMM)
I led the end-to-end development of the structured bond valuation and risk management framework, simulating the daily operations of an interest rate derivatives desk:

* **Volatility Calibration:** Bootstrapped piecewise-constant LMM spot volatilities from market-quoted flat cap volatilities using custom root-finding routines to isolate forward-rate dynamics across maturity buckets.
* **Smile-Adjusted Pricing:** Priced a 10-year structured bond with exotic piecewise coupons. Implemented a volatility smile correction to the flat-volatility Black-76 model, evaluating the slope of the implied volatility surface ($\partial\sigma/\partial K$) via cubic spline interpolation to accurately price the embedded digital risk.
* **Delta Bucket Hedging:** Computed partial and total Bucket DV01s (accounting for LMM recalibration post-curve shock) and executed a coarse-grained bucket hedge using 2y, 6y, and 10y interest rate swaps via exact and backward-substitution linear systems.
* **Vega Bucket Hedging:** Calculated Total Vega via central finite differences (recalibrating the LMM at each bump) and structured a Vega bucket hedge using 6y and 10y ATM caps.

## Broader Framework Modules (Collaborative Work)
Working alongside my peers, I contributed to the valuation of a path-dependent exotic cap under the Bond Market Model (BMM):
* **Stochastic Strike Evaluation:** Modeled an exotic cap whose strike dynamically depends on previous LIBOR fixings.
* **Monte Carlo Engines:** Co-developed two independent pricing methods for cross-validation:
  1. *Full Path Simulation (Spot Measure):* Direct simulation of forward Zero-Coupon Bond (ZCB) ratios with stochastic discounting.
  2. *Conditional Monte Carlo (Forward Measure):* Variance-reduced approach combining simulation up to the fixing date with an analytical Black-type conditional pricing step.

## Key Results
* **Digital Mispricing:** Demonstrated that neglecting the volatility skew overprices the structured bond's upfront by over €108,000, proving the necessity of smile-adjusted pricing.
* **Hedging Precision:** Successfully neutralized both bucket Delta and Vega exposures to near-zero residuals.
* **Pricing Convergence:** Achieved strict statistical consistency between Spot and Forward measure Monte Carlo estimators for the exotic cap.

## Tech Stack
* **Language:** MATLAB
* **Quantitative Methods:** LIBOR Market Model (LMM), Bond Market Model (BMM), Bucket Hedging (DV01/Vega), Monte Carlo Simulation (Spot/Forward Measures), Volatility Smile Correction, Root-finding Algorithms.
