## Review
第一次用SRAM的LAB，超級痛苦。因為時間關係，所以一開始決定架構、開怎樣的SRAM就很重要，基本上沒有時間嘗試第二種架構。
## Suggestion
這次的performance是area-dominant，而SRAM又是面積超大，所以要盡量縮小SRAM的面積。

當時我朋友花了很多時間測試要開怎麼樣的SRAM最area-efficient，最後得出的結論是只開一個最好，盡量避免多開。因為面積考量的關係，我們一開始都覺得用single-port應該比dual-port來得好，沒想到後來用single-port的控制超難寫，複雜到我們的performance也不一定比dual-port好，但真的沒時間再改成用dual-port。

SRAM的一個word我們一開始是覺得越長越好，因為是讀取圖片，我們想說讀寫次數越少應該越單純。結果確實如此，不考慮APR的話，一個word越長是越好寫，我自己是開64x128，等於我一行pixel最多只需讀兩次。

我們這次的[Lab11](https://github.com/CharlieG03/IC_Lab_2024_Fall/tree/main/Lab11)正好就是用這個lab去A，所以一個word太長又會面臨SRAM的layout變成長方形，導致APR的時候util要開很低才放得下，最後chip area會比gate area大很多，有點這個lab縮面積是白忙一場的感覺。

雖然我沒有寫dual-port的版本，但我朋友後來只開一個dual-port，這個lab跟lab11排名都比我前面的多，所以應該是要用dual-port才是好寫又好A。
