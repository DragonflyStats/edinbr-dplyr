

library(tidyverse)
#tidyverse tweets
tidyweb is a part of the tidyverse, an ecosystem of packages designed with common APIs and a shared philosophy. Learn more at tidyverse.org.


You can get the length of the string with str_length():

str_length("abc")
#> [1] 3
This is now equivalent to the base R function nchar(). Previously it was needed to work around issues with nchar() such as the fact that it returned 2 for nchar(NA). This has been fixed as of R 3.3.0, so it is no longer so important.

You can access individual character using sub_str(). It takes three arguments: a character vector, a starting position and an end position. Either position can either be a positive integer, which counts from the length, or a negative integer which counts from the right. The positions are inclusive, and if longer than the string, will be silently truncated.

x <- c("abcdef", "ghifjk")

# The 3rd letter
str_sub(x, 3, 3)
#> [1] "c" "i"



# The 2nd to 2nd-to-last character
str_sub(x, 2, -2)
#> [1] "bcde" "hifj"


You can also use str_sub() to modify strings:

str_sub(x, 3, 3) <- "X"
x
#> [1] "abXdef" "ghXfjk"


To duplicate individual strings, you can use str_dup():

str_dup(x, c(2, 3))
#> [1] "abXdefabXdef"       "ghXfjkghXfjkghXfjk"
Whitespace

Three functions add, remove, or modify whitespace:


str_pad() pads a string to a fixed length by adding extra whitespace on the left, right, or both sides.

x <- c("abc", "defghi")
str_pad(x, 10)
#> [1] "       abc" "    defghi"
str_pad(x, 10, "both")
#> [1] "   abc    " "  defghi  "


(You can pad with other characters by using the pad argument.)

str_pad() will never make a string shorter:

str_pad(x, 4)
#> [1] " abc"   "defghi"


So if you want to ensure that all strings are the same length (often useful for print methods), combine str_pad() and str_trunc():



x <- c("Short", "This is a long string")

x %>% 
  str_trunc(10) %>% 
  str_pad(10, "right")
#> [1] "Short     " "This is..."


The opposite of str_pad() is str_trim(), which removes leading and trailing whitespace:

x <- c("  a   ", "b   ",  "   c")
str_trim(x)
#> [1] "a" "b" "c"
str_trim(x, "left")
#> [1] "a   " "b   " "c"
You can use str_wrap() to modify existing whitespace in order to wrap a paragraph of text so that the length of each line as a similar as possible.



jabberwocky <- str_c(
  "`Twas brillig, and the slithy toves ",
  "did gyre and gimble in the wabe: ",
  "All mimsy were the borogoves, ",
  "and the mome raths outgrabe. "
)

cat(str_wrap(jabberwocky, width = 40))
#> `Twas brillig, and the slithy toves did
#> gyre and gimble in the wabe: All mimsy
#> were the borogoves, and the mome raths
#> outgrabe.
Locale sensitive

A handful of stringr are functions are locale-sensitive: they will perform differently in different regions of the world. These functions case transformation functions:



x <- "I like horses."
str_to_upper(x)
#> [1] "I LIKE HORSES."
str_to_title(x)
#> [1] "I Like Horses."

str_to_lower(x)
#> [1] "i like horses."
# Turkish has two sorts of i: with and without the dot
str_to_lower(x, "tr")
#> [1] "Ä± like horses."


And string ordering and sorting:
```{r}
x <- c("y", "i", "k")
str_order(x)
#> [1] 2 3 1

str_sort(x)
#> [1] "i" "k" "y"
# In Lithuanian, y comes between i and k
str_sort(x, locale = "lt")
#> [1] "i" "y" "k"
```

The locale always defaults to English to ensure that the default behaviour is identically across systems. Locales always include a two letter ISO-639-1 language code (like âenâ for English or âzhâ for Chinese), and optionally a ISO-3166 country code (like âen_UKâ vs âen_USâ). You can see a complete list of available locales by running stringi::stri_locale_list().

#### Pattern matching

The vast majority of stringr functions work with patterns. These are parameterised by the task they perform and the types of patterns they match.

#### Tasks

Each pattern matching function has the same first two arguments, a character vector of strings to process and a single pattern to match. stringr provides pattern matching functions to detect, locate, extract, match, replace, and split strings. Iâll illustrate how they work with some strings and a regular expression designed to match (US) phone numbers:


```{r}
strings <- c(
  "apple", 
  "219 733 8965", 
  "329-293-8753", 
  "Work: 579-499-7527; Home: 543.355.3679"
)
phone <- "([2-9][0-9]{2})[- .]([0-9]{3})[- .]([0-9]{4})"
```


`str_detect()` detects the presence or absence of a pattern and returns a logical vector (similar to grepl()). str_subset() returns the elements of a character vector that match a regular expression (similar to grep() with value = TRUE)`.

# Which strings contain phone numbers?
str_detect(strings, phone)
#> [1] FALSE  TRUE  TRUE  TRUE
str_subset(strings, phone)
#> [1] "219 733 8965"                          
#> [2] "329-293-8753"                          
#> [3] "Work: 579-499-7527; Home: 543.355.3679"
str_count() counts the number of matches:
```{r}

# How many phone numbers in each string?
str_count(strings, phone)
#> [1] 0 1 1 2
str_locate() locates the first position of a pattern and returns a numeric matrix with columns start and end. str_locate_all() locates all matches, returning a list of numeric matrices. Similar to regexpr() and gregexpr().

# Where in the string is the phone number located?
(loc <- str_locate(strings, phone))
#>      start end
#> [1,]    NA  NA
#> [2,]     1  12
#> [3,]     1  12
#> [4,]     7  18


str_locate_all(strings, phone)
#> [[1]]
#>      start end
#> 
#> [[2]]
#>      start end
#> [1,]     1  12
#> 
#> [[3]]
#>      start end
#> [1,]     1  12
#> 
#> [[4]]
#>      start end
#> [1,]     7  18
#> [2,]    27  38
```




`str_extract()` extracts text corresponding to the first match, returning a character vector. str_extract_all() extracts all matches and returns a list of character vectors.

```{r}
# What are the phone numbers?
str_extract(strings, phone)
#> [1] NA             "219 733 8965" "329-293-8753" "579-499-7527"
str_extract_all(strings, phone)



#> [[1]]
#> character(0)
#> 
#> [[2]]
#> [1] "219 733 8965"
#> 
#> [[3]]
#> [1] "329-293-8753"
#> 
#> [[4]]
#> [1] "579-499-7527" "543.355.3679"
str_extract_all(strings, phone, simplify = TRUE)
#>      [,1]           [,2]          
#> [1,] ""             ""            
#> [2,] "219 733 8965" ""            
#> [3,] "329-293-8753" ""            
#> [4,] "579-499-7527" "543.355.3679"
```

str_match() extracts capture groups formed by () from the first match. It returns a character matrix with one column for the complete match and one column for each group. str_match_all() extracts capture groups from all matches and returns a list of character matrices. Similar to regmatches().

# Pull out the three components of the match
str_match(strings, phone)
#>      [,1]           [,2]  [,3]  [,4]  
#> [1,] NA             NA    NA    NA    
#> [2,] "219 733 8965" "219" "733" "8965"
#> [3,] "329-293-8753" "329" "293" "8753"
#> [4,] "579-499-7527" "579" "499" "7527"


str_match_all(strings, phone)
#> [[1]]
#>      [,1] [,2] [,3] [,4]
#> 
#> [[2]]
#>      [,1]           [,2]  [,3]  [,4]  
#> [1,] "219 733 8965" "219" "733" "8965"
#> 
#> [[3]]
#>      [,1]           [,2]  [,3]  [,4]  
#> [1,] "329-293-8753" "329" "293" "8753"
#> 
#> [[4]]
#>      [,1]           [,2]  [,3]  [,4]  
#> [1,] "579-499-7527" "579" "499" "7527"
#> [2,] "543.355.3679" "543" "355" "3679"


str_replace() replaces the first matched pattern and returns a character vector. str_replace_all() replaces all matches. Similar to sub() and gsub().


str_replace(strings, phone, "XXX-XXX-XXXX")
#> [1] "apple"                                 
#> [2] "XXX-XXX-XXXX"                          
#> [3] "XXX-XXX-XXXX"                          
#> [4] "Work: XXX-XXX-XXXX; Home: 543.355.3679"
str_replace_all(strings, phone, "XXX-XXX-XXXX")
#> [1] "apple"                                 
#> [2] "XXX-XXX-XXXX"                          
#> [3] "XXX-XXX-XXXX"                          
#> [4] "Work: XXX-XXX-XXXX; Home: XXX-XXX-XXXX"


str_split_fixed() splits the string into a fixed number of pieces based on a pattern and returns a character matrix. str_split() splits a string into a variable number of pieces and returns a list of character vectors.
```{r}
str_split("a-b-c", "-")
#> [[1]]
#> [1] "a" "b" "c"
str_split_fixed("a-b-c", "-", n = 2)
#>      [,1] [,2] 
#> [1,] "a"  "b-c"
```

Fixed matches

fixed(x) only matches the exact sequence of bytes specified by x. This is a very limited âpatternâ, but the restriction can make matching much faster. Beware using fixed() with non-English data. It is problematic because there are often multiple ways of representing the same character. For example, there are two ways to define âÃ¡â: either as a single character or as an âaâ plus an accent:

a1 <- "\u00e1"
a2 <- "a\u0301"
c(a1, a2)
#> [1] "Ã¡" "aÌ"
a1 == a2
#> [1] FALSE


They render identically, but because theyâre defined differently, fixed() doesnât find a match. Instead, you can use coll(), defined next, to respect human character comparison rules:

str_detect(a1, fixed(a2))
#> [1] FALSE
str_detect(a1, coll(a2))
#> [1] TRUE


Collation search

coll(x) looks for a match to x using human-language collation rules, and is particularly important if you want to do case insensitive matching. Collation rules diffe around the world, so youâll also need to supply a locale parameter.

i <- c("I", "Ä°", "i", "Ä±")
i
#> [1] "I" "Ä°" "i" "Ä±"



str_subset(i, coll("i", ignore_case = TRUE))
#> [1] "I" "i"
str_subset(i, coll("i", ignore_case = TRUE, locale = "tr"))
#> [1] "Ä°" "i"
The downside of coll() is speed; because the rules for recognising which characters are the same are complicated, coll() is relatively slow compared to regex() and fixed(). Note that will both fixed() and regex() have ignore_case arguments, they perform a much simpler comparison than coll().




x <- "This is a sentence."
str_split(x, boundary("word"))
#> [[1]]
#> [1] "This"     "is"       "a"        "sentence"
str_count(x, boundary("word"))
#> [1] 4
str_extract_all(x, boundary("word"))
#> [[1]]
#> [1] "This"     "is"       "a"        "sentence"



str_split(x, "")
#> [[1]]
#>  [1] "T" "h" "i" "s" " " "i" "s" " " "a" " " "s" "e" "n" "t" "e" "n" "c"
#> [18] "e" "."
str_count(x, "")
#> [1] 19


