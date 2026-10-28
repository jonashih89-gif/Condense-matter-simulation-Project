# Kronig-Penney Interactive Simulator

An interactive MATLAB dashboard that visualizes the electronic band structure of the **Kronig-Penney model** — a 1D periodic potential that shows how allowed energy bands and forbidden gaps arise in a crystal — and extends it to a **3D Fermi surface** for a simple cubic lattice.

## Physics Background

In the delta-function (strong, thin barrier) limit, the Kronig-Penney model gives the condition

$$
f(\alpha a) = P\,\frac{\sin(\alpha a)}{\alpha a} + \cos(\alpha a) = \cos(ka),
\qquad \alpha = \frac{\sqrt{2mE}}{\hbar}
$$

where $P$ is the barrier strength, $a$ the lattice constant, and $k$ the crystal momentum. Since $|\cos(ka)| \le 1$, an energy is **allowed** only when $|f(\alpha a)| \le 1$; all other energies form **band gaps**.

## What the Program Shows

**Fig 1 – Graphical Solution (top left).** Plots $f(\alpha a)$ together with the lines $\pm 1$. Shaded regions mark the allowed bands.

**Fig 2 – E–k Diagram (top right).** Solves $k = \cos^{-1}[f(\alpha a)]/a$ for each allowed energy and plots the band structure in the extended-zone scheme, with $E \propto (\alpha a)^2$. The gaps at $ka = n\pi$ are clearly visible.

**Fig 3 – 3D Fermi Surface (bottom).** Assumes a separable 3D potential (Kronig-Penney along each axis), so the first-band energy is $E(\mathbf{k}) = E(k_x) + E(k_y) + E(k_z)$. The Fermi surface is drawn as an isosurface inside the first Brillouin zone $[-\pi, \pi]^3$ (dashed box). At low filling it is nearly spherical (free-electron-like); as filling increases it deforms and touches the zone boundary.

## Controls

| Slider | Range | Effect |
|---|---|---|
| Barrier Strength (P') | 0.1 – 20 | Larger P → narrower bands and wider gaps (tight-binding limit); smaller P → nearly free electrons. Updates all figures. |
| 1D Plot Range (n·π) | 1.5π – 6π | Zooms the horizontal range of Fig 1 and Fig 2. |
| Fermi Filling Factor | 0.02 – 0.98 | Sets the Fermi energy as a fraction between the minimum and maximum band energy. Updates Fig 3. |

Fig 3 can be rotated with the mouse.

## How to Run

1. Open MATLAB (uses only built-in functions; no toolboxes required).
2. Put `finalproject.m` in your working folder.
3. Run:

   ```matlab
   finalproject
   ```

## Notes

- Energies are shown in dimensionless units, $(\alpha a)^2 \propto E$.
- The 3D grid uses 35 points per axis to keep the sliders responsive; increase `grid_N` for a smoother surface at the cost of speed.
