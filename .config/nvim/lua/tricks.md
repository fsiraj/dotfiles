# Vim Tricks and Tips

- Recording macros:
  - `qq{...}q` then `[count]Q`
  - Record ... into register q, then repeat last recorded register.
- Format multi-line code to single-line:
  - `V[count]{motion}J`
  - Visually select lines and Join them.
- Block indent/unindent:
  - `V[count]{motion}[count]{>|<}`
  - Visually select lines and Shift them.
