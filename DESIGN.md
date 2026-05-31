---
name: Secure Modernism
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#424753'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#727784'
  outline-variant: '#c2c6d5'
  surface-tint: '#005ac2'
  primary: '#004496'
  on-primary: '#ffffff'
  primary-container: '#005bc4'
  on-primary-container: '#cbdaff'
  inverse-primary: '#adc6ff'
  secondary: '#006e20'
  on-secondary: '#ffffff'
  secondary-container: '#7ff984'
  on-secondary-container: '#007322'
  tertiary: '#3d485c'
  on-tertiary: '#ffffff'
  tertiary-container: '#556074'
  on-tertiary-container: '#d0dbf3'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#004395'
  secondary-fixed: '#82fc87'
  secondary-fixed-dim: '#66df6e'
  on-secondary-fixed: '#002205'
  on-secondary-fixed-variant: '#005316'
  tertiary-fixed: '#d8e3fb'
  tertiary-fixed-dim: '#bcc7de'
  on-tertiary-fixed: '#111c2d'
  on-tertiary-fixed-variant: '#3c475a'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-max: 1280px
  gutter: 24px
  margin-desktop: 40px
  margin-mobile: 16px
---

## Brand & Style

The design system is anchored in the principles of trust, security, and professional efficiency. It is designed for financial agents who require a workspace that feels both technologically advanced and rock-solid. The aesthetic follows a **Corporate Modern** approach with a refined, clean execution.

The visual language is inspired by the shield motif: protective yet accessible. It avoids unnecessary decorative flourishes, opting instead for high-quality typography, a disciplined color application, and a structural layout that prioritizes data legibility and user confidence. The emotional response should be one of "controlled growth" and "absolute reliability."

## Colors

The palette is derived directly from the core brand identity to ensure a seamless transition from logo to interface.

*   **Primary (Trust Blue):** Used for primary actions, branding elements, and active states. It represents stability and institutional strength.
*   **Secondary (Growth Green):** Utilized for success states, financial gains, and secondary calls to action. It balances the blue with a sense of vitality and progress.
*   **Tertiary (Midnight Slate):** Used for high-contrast text and dark-mode headers to provide depth and professional weight.
*   **Neutrals:** A scale of cool grays provides the necessary scaffolding for the interface, ensuring the primary colors remain impactful without overwhelming the user.

## Typography

This design system utilizes **Inter** exclusively to maintain a utilitarian and systematic feel. The typeface’s high x-height and neutral character make it ideal for data-heavy financial dashboards.

Headlines use a tighter letter-spacing and heavier weights to command attention and imply strength. Body text is optimized for readability with generous line heights. Small labels use a medium weight and slight tracking to ensure legibility in dense UI environments like tables and form fields.

## Layout & Spacing

The layout follows a **Fluid Grid** system based on an 8px square scale. This ensures all elements align to a consistent rhythmic cadence.

*   **Grid:** A 12-column grid is used for desktop environments to allow for complex dashboard widgets and data tables. On mobile, this collapses to a single-column layout with 16px side margins.
*   **Rhythm:** Vertical spacing between sections should be 48px or 64px, while internal component spacing should stay within the 8px-24px range.
*   **Safe Areas:** Content should be contained within a maximum width of 1280px on large screens to maintain eye-tracking comfort.

## Elevation & Depth

Elevation is handled through **Tonal Layers** and **Ambient Shadows** to create a sense of organized hierarchy without cluttering the interface.

*   **Background:** The lowest layer is a very light cool gray (#F8FAFC).
*   **Surface-Low:** Used for cards and containers. These feature a subtle 1px border (#E2E8F0) and no shadow to keep the interface flat and fast.
*   **Surface-High:** Used for modals, dropdowns, and elevated action panels. These utilize a diffused, low-opacity shadow (0px 4px 20px rgba(0, 0, 0, 0.05)) to suggest they are floating above the workspace.
*   **Interactive Depth:** On hover, buttons and cards should transition with a slight scale increase (1.02x) rather than heavy shadow changes to maintain the modern feel.

## Shapes

The shape language reflects the "Shield" concept: secure but not rigid.

We use a **Rounded** (Level 2) approach. Standard components like buttons and inputs feature a 0.5rem (8px) radius. Larger containers and cards use a 1rem (16px) radius. This specific level of roundness softens the "corporate" edge while appearing more modern than sharp 90-degree corners. It echoes the outer curves of the brand logo, creating visual harmony across the entire platform.

## Components

### Buttons
*   **Primary:** Solid Primary Blue background with white text. High-contrast and clear.
*   **Secondary:** Solid Secondary Green background. Used for "Success" actions like finalizing a transaction.
*   **Ghost:** Transparent background with Primary Blue border and text. Used for less prominent actions.

### Input Fields
Inputs should have a white background, an 8px corner radius, and a subtle slate border. On focus, the border should transition to Primary Blue with a soft 2px outer glow in the same color (20% opacity).

### Cards
Cards are the primary container for data. They must feature a white background, a 16px corner radius, and a light-gray border. Avoid heavy shadows unless the card is being dragged or is part of a temporary overlay.

### Chips & Status Indicators
Status chips use a "Tinted" style: a light background version of the status color (e.g., 10% Green) with high-contrast text of the same hue. This ensures that "Success," "Pending," or "Alert" states are immediately recognizable without being visually aggressive.

### Tables
Financial data must be presented in clean tables with horizontal dividers only. Header rows should have a slight gray background to differentiate them from the data rows. Use monospaced numerals if the data includes frequent currency alignment.