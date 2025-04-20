# Window crowparator

Window comparator for crow, with optional norns UI.

## Inputs and outputs

    → 1 window center
    → 2 input
      1 above   →
      2 inside  →
      3 outside →
      4 below   →

The crow script is in the file `crow/window-crowparator.lua` which can run alone on crow alone.

If you use the optional norns interface, then <kbd>E1</kbd>, <kbd>E2</kbd> and <kbd>E3</kbd> change the three parameters for window width, truth voltage and falsehood voltage.

Set window width in params. Also redefine truth and non-truth there to be what you wish.

## Requirements

- crow

norns optional.

## Installation

### crow

In the `crow/` directory you will find `window-crowparator.lua`. Run or upload it using druid.

### norns

For norns, do the usual

```
;install https://github.com/xmacex/window-crowparator
```
