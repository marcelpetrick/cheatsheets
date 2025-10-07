# Convert humand readable dates into hours (coming for instance from Gitlab)
```
=LET(
  s, TRIM(X2),
  tokens, IF(s="", "", TEXTSPLIT(s, " ")),
  nums, --SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(tokens,"w",""),"d",""),"h",""),"m",""),
  units, RIGHT(tokens,1),
  IF(s="","",
     SUM( IF(units="w", nums*40,
         IF(units="d", nums*8,
         IF(units="h", nums,
         IF(units="m", nums/60, 0)))))
  )
)
```
