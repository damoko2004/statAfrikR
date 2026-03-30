# Standardiser les âges déclarés

Détecte et corrige le "heap effect" (attraction vers les âges ronds)
fréquent dans les enquêtes africaines où les âges sont déclarés. Calcule
l'indice de Whipple et l'indice de Myers pour évaluer la qualité.

## Usage

``` r
standardiser_ages(
  data,
  var_age = "age",
  methode = c("aucune", "interpolation", "united_nations"),
  age_min = 0L,
  age_max = 120L
)
```

## Arguments

- data:

  data.frame ou tibble — Données

- var_age:

  character — Nom de la variable d'âge

- methode:

  character — Méthode de correction : `"aucune"` (diagnostic
  uniquement), `"interpolation"` (répartition uniforme autour des âges
  ronds), `"united_nations"` (méthode Nations Unies). Défaut : "aucune".

- age_min:

  integer — Âge minimum valide. Défaut : 0.

- age_max:

  integer — Âge maximum valide. Défaut : 120.

## Value

Une liste avec :

- donnees:

  tibble avec âges corrigés si methode != "aucune"

- indice_whipple:

  numeric — Indice de Whipple (1 = parfait, \> 1.05 = problème)

- indice_myers:

  numeric — Indice de Myers (0 = parfait)

- diagnostic:

  character — Évaluation de la qualité

## Examples

``` r
# \donttest{
  donnees <- data.frame(age = sample(0:80, 200, replace=TRUE))
  standardiser_ages(donnees, var_age="age")
#> === Diagnostic qualité des âges ===
#> Indice de Whipple : 1.143 (Qualité acceptable)
#> Indice de Myers   : 7.16
#> $donnees
#>     age
#> 1    79
#> 2     2
#> 3    12
#> 4    11
#> 5    64
#> 6    29
#> 7    50
#> 8    59
#> 9    36
#> 10   46
#> 11   55
#> 12   69
#> 13   15
#> 14    9
#> 15   70
#> 16   72
#> 17   24
#> 18    2
#> 19   52
#> 20   27
#> 21   78
#> 22   56
#> 23   79
#> 24   60
#> 25   42
#> 26   21
#> 27   25
#> 28   53
#> 29   53
#> 30   54
#> 31   53
#> 32   57
#> 33   44
#> 34   36
#> 35   42
#> 36   78
#> 37   33
#> 38   24
#> 39   64
#> 40   13
#> 41   48
#> 42   10
#> 43   27
#> 44   17
#> 45   54
#> 46   41
#> 47   35
#> 48   19
#> 49   78
#> 50   60
#> 51   70
#> 52   26
#> 53    4
#> 54   19
#> 55   40
#> 56   10
#> 57   37
#> 58   72
#> 59   22
#> 60   10
#> 61   18
#> 62   35
#> 63   41
#> 64   53
#> 65   58
#> 66   29
#> 67   58
#> 68   20
#> 69   69
#> 70   46
#> 71   73
#> 72   54
#> 73    6
#> 74   13
#> 75   11
#> 76   52
#> 77   50
#> 78    9
#> 79   36
#> 80   65
#> 81   34
#> 82   33
#> 83   26
#> 84   45
#> 85   30
#> 86   79
#> 87   52
#> 88   23
#> 89   37
#> 90   19
#> 91   74
#> 92   77
#> 93   32
#> 94   35
#> 95   44
#> 96   21
#> 97   43
#> 98   63
#> 99    6
#> 100   4
#> 101  30
#> 102  31
#> 103  38
#> 104  12
#> 105  29
#> 106  53
#> 107   1
#> 108  27
#> 109   2
#> 110  32
#> 111   8
#> 112  53
#> 113   9
#> 114  70
#> 115  24
#> 116  73
#> 117  72
#> 118  18
#> 119  78
#> 120  45
#> 121   2
#> 122  21
#> 123  60
#> 124  19
#> 125  41
#> 126  16
#> 127  45
#> 128  16
#> 129  73
#> 130  36
#> 131  44
#> 132  49
#> 133  50
#> 134  73
#> 135  47
#> 136  33
#> 137  57
#> 138  67
#> 139  60
#> 140  32
#> 141  18
#> 142  69
#> 143  29
#> 144   1
#> 145  37
#> 146   8
#> 147  55
#> 148  74
#> 149   5
#> 150  30
#> 151  68
#> 152  13
#> 153  63
#> 154  46
#> 155  64
#> 156  40
#> 157   9
#> 158  48
#> 159  75
#> 160  21
#> 161   0
#> 162   3
#> 163  66
#> 164  58
#> 165  52
#> 166  37
#> 167  58
#> 168  68
#> 169  41
#> 170  61
#> 171  19
#> 172  33
#> 173  56
#> 174  19
#> 175   8
#> 176  26
#> 177  45
#> 178  45
#> 179   2
#> 180  62
#> 181  17
#> 182   9
#> 183  39
#> 184  52
#> 185  69
#> 186  28
#> 187  67
#> 188   8
#> 189  39
#> 190  75
#> 191  73
#> 192  53
#> 193  56
#> 194  26
#> 195  79
#> 196  27
#> 197  14
#> 198  22
#> 199  60
#> 200   9
#> 
#> $indice_whipple
#> [1] 1.143
#> 
#> $indice_myers
#> [1] 7.16
#> 
#> $diagnostic
#> [1] "Qualité acceptable"
#> 
# }
```
