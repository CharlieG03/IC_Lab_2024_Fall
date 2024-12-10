`define CYCLE_TIME 20.0

module PATTERN #(parameter IP_BIT = 6)(
    //Output Port
    IN_code,
    //Input Port
	OUT_code
);
//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
output reg [IP_BIT+4-1:0] IN_code;

input [IP_BIT-1:0] OUT_code;
//---------------------------------------------------------------------
//  CLOCK
//---------------------------------------------------------------------
reg clk;
real CYCLE = `CYCLE_TIME;
always #(CYCLE/2.0) clk = ~clk;
initial	clk = 0;
//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
integer PATNUM = 300;
integer patcount;
integer pos;
//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
reg xor_temp [0:15];
reg [IP_BIT-1:0] random_code;
reg encoding [1:IP_BIT+4];
reg [IP_BIT+4-1:0] encoded_code;
reg [IP_BIT-1:0] decoded_code;
//---------------------------------------------------------------------
//   INITIAL
//---------------------------------------------------------------------
initial begin
    IN_code = 'bx;
    repeat(5) @(negedge clk);

	for(patcount = 0; patcount < PATNUM; patcount++) begin
        $display("\033[0;34mPATTERN NO.%d:", patcount);		
        encode_task;
        IN_code = encoded_code;
        $display("\033[0;37mIN_code              = %b", IN_code);
        repeat(1) @(negedge clk);

		check_ans;
		repeat($urandom_range(3, 5)) @(negedge clk);
	end
	print_pass_usagi;
    repeat(3) @(negedge clk);
    $finish;
end

//---------------------------------------------------------------------
//   TASK
//---------------------------------------------------------------------
task encode_task; begin
    for (integer i = 0; i < IP_BIT; i++)
        random_code[i] = $urandom_range(0,1);
    
    $display("\033[0;37mOriginal random code = %b", random_code);

    for (integer i = 1; i <= IP_BIT + 4; i++)
        encoding[i] = 0;
    
    for (integer i = 1; i <= IP_BIT; i++) begin
        if (i == 1)
            encoding[3] = random_code[IP_BIT - i];
        else if (i <= 4)
            encoding[i + 3] = random_code[IP_BIT - i];
        else encoding[i + 4] = random_code[IP_BIT - i];
    end

    encoding[1] = 0; encoding[2] = 0;
    encoding[4] = 0; encoding[8] = 0;

    for (integer i = 1; i <= IP_BIT + 4; i++) begin
        if (i == 1 || i == 2 || i == 4 || i == 8)
            continue;
        if (i[0])
            encoding[1] = encoding[1] ^ encoding[i];
        if (i[1])
            encoding[2] = encoding[2] ^ encoding[i];
        if (i[2])
            encoding[4] = encoding[4] ^ encoding[i];
        if (i[3])
            encoding[8] = encoding[8] ^ encoding[i];
    end

    for (integer i = 1; i <= IP_BIT + 4; i++) begin
        encoded_code[IP_BIT + 4 - i] = encoding[i];
    end
    $display("\033[0;37mCorrect encoded code = %b", encoded_code);
    pos = $urandom_range(0, 2*IP_BIT + 7);

    if (pos < IP_BIT + 4) begin
        encoded_code[pos] = ~encoded_code[pos];
    end
end endtask

task check_ans; begin
    // decode
    if (OUT_code !== random_code) begin
        print_fail_usagi;
        $display ("-------------------------------------------------------------------");
		$display("*                            PATTERN NO.%4d 	                      ", patcount);
        $display ("         ans should be : %b , your answer is : %b           ", random_code, OUT_code);
        $display ("-------------------------------------------------------------------");
        #(100);
        $finish ;
    end
    else begin
        $display("\033[0;37mDecoded code (OUT_code) = %b", OUT_code);
        $display("\033[0;34mPASS PATTERN NO.%d", patcount);
    end

end endtask

task print_pass_usagi; begin
	$display("\033[37m                                  .$&X.      x$$x              \033[32m      :BBQvi.");
	$display("\033[37m                                .&&;.X&$  :&&$+X&&x            \033[32m     BBBBBBBBQi");
	$display("\033[37m                               +&&    &&.:&$    .&&            \033[32m    :BBBP :7BBBB.");
	$display("\033[37m                              :&&     &&X&&      $&;           \033[32m    BBBB     BBBB");
	$display("\033[37m                              &&;..   &&&&+.     +&+           \033[32m   iBBBv     BBBB       vBr");
	$display("\033[37m                             ;&&...   X&&&...    +&.           \033[32m   BBBBBKrirBBBB.     :BBBBBB:");
	$display("\033[37m                             x&$..    $&&X...    +&            \033[32m  rBBBBBBBBBBBR.    .BBBM:BBB");
	$display("\033[37m                             X&;...   &&&....    &&            \033[32m  BBBB   .::.      EBBBi :BBU");
	$display("\033[37m                             $&...    &&&....    &&            \033[32m MBBBr           vBBBu   BBB.");
	$display("\033[37m                             $&....   &&&...     &$            \033[32m i7PB          iBBBBB.  iBBB");
	$display("\033[37m                             $&....   &&& ..    .&x                        \033[32m  vBBBBPBBBBPBBB7       .7QBB5i");
	$display("\033[37m                             $&....   &&& ..    x&+                        \033[32m :RBBB.  .rBBBBB.      rBBBBBBBB7");
	$display("\033[37m                             X&;...   x&&....   &&;                        \033[32m    .       BBBB       BBBB  :BBBB");
	$display("\033[37m                             x&X...    &&....   &&:                        \033[32m           rBBBr       BBBB    BBBU");
	$display("\033[37m                             :&$...    &&+...   &&:                        \033[32m           vBBB        .BBBB   :7i.");
	$display("\033[37m                              &&;...   &&$...   &&:                        \033[32m             .7  BBB7   iBBBg");
	$display("\033[37m                               && ...  X&&...   &&;                                         \033[32mdBBB.   5BBBr");
	$display("\033[37m                               .&&;..  ;&&x.    $&;.$&$x;                                   \033[32m ZBBBr  EBBBv     YBBBBQi");
	$display("\033[37m                               ;&&&+   .+xx;    ..  :+x&&&&&&&x                             \033[32m  iBBBBBBBBD     BBBBBBBBB.");
	$display("\033[37m                        +&&&&&&X;..             .          .X&&&&&x                         \033[32m    :LBBBr      vBBBi  5BBB");
	$display("\033[37m                    $&&&+..                                    .:$&&&&.                     \033[32m          ...   :BBB:   BBBu");
	$display("\033[37m                 $&&$.                                             .X&&&&.                  \033[32m         .BBBi   BBBB   iMBu");
	$display("\033[37m              ;&&&:                                               .   .$&&&                x\033[32m          BBBX   :BBBr");
	$display("\033[37m            x&&x.      .+&&&&&.                .x&$x+:                  .$&&X         $+  &x  ;&X   \033[32m  .BBBv  :BBBQ");
	$display("\033[37m          .&&;       .&&&:                      .:x$&&&&X                 .&&&        ;&     +&.    \033[32m   .BBBBBBBBB:");
	$display("\033[37m         $&&       .&&$.                             ..&&&$                 x&& x&&&X+.          X&x\033[32m     rBBBBB1.");
	$display("\033[37m        &&X       ;&&:                                   $&&x                $&x   .;x&&&&:                       ");
	$display("\033[37m      .&&;       ;&x                                      .&&&                &&:       .$&&$    ;&&.             ");
	$display("\033[37m      &&;       .&X                                         &&&.              :&$          $&&x                   ");
	$display("\033[37m     x&X       .X& .                                         &&&.              .            ;&&&  &&:             ");
	$display("\033[37m     &&         $x                                            &&.                            .&&&                 ");
	$display("\033[37m    :&&                                                       ;:                              :&&X                ");
	$display("\033[37m    x&X                 :&&&&&;                ;$&&X:                                          :&&.               ");
	$display("\033[37m    X&x .              :&&&  $&X              &&&  X&$                                          X&&               ");
	$display("\033[37m    x&X                x&&&&&&&$             :&&&&$&&&                                          .&&.              ");
	$display("\033[37m    .&&    \033[38;2;255;192;203m      ....\033[37m  .&&X:;&&+              &&&++;&&                                          .&&               ");
	$display("\033[37m     &&    \033[38;2;255;192;203m  .$&.x+..:\033[37m  ..+Xx.                 :&&&&+\033[38;2;255;192;203m  .;......    \033[37m                             .&&");
	$display("\033[37m     x&x   \033[38;2;255;192;203m .x&:;&x:&X&&.\033[37m              .             \033[38;2;255;192;203m .&X:&&.&&.:&.\033[37m                             :&&");
	$display("\033[37m     .&&:  \033[38;2;255;192;203m  x;.+X..+.;:.\033[37m         ..  &&.            \033[38;2;255;192;203m &X.;&:+&$ &&.\033[37m                             x&;");
	$display("\033[37m      :&&. \033[38;2;255;192;203m    .......   \033[37m         x&&&&&$++&$        \033[38;2;255;192;203m .... ......: \033[37m                             && ");
	$display("\033[37m       ;&&                          X&  .x.              \033[38;2;255;192;203m .... \033[37m                               .&&;                ");
	$display("\033[37m        .&&x                        .&&$X                                          ..         .x&&&               ");
	$display("\033[37m          x&&x..                                                                 :&&&&&+         +&X              ");
	$display("\033[37m            ;&&&:                                                                     x&&$XX;::x&&X               ");
	$display("\033[37m               &&&&&:.                                                              .X&x    +xx:                  ");
	$display("\033[37m                  ;&&&&&&&&$+.                                  :+x&$$X$&&&&&&&&&&&&&$                            ");
	$display("\033[37m                       .+X$&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&$X+xXXXxxxx+;.                                   ");
// light pink blush: \033[38;2;255;192;203m
// character: 125 pixels
// contrast: 180%
end endtask

task print_fail_usagi; begin                                                                                                                         
	$display("\033[37m                                                                         x&&&&X  +&&&&&&+                                    ");
	$display("\033[37m                                                                      .&&&&$$&&&&&&+ .&&&&                                   ");
	$display("\033[37m                                                                     X&&&;   &&&&$     X&&&                                  ");
	$display("\033[31m i:..::::::i.      :::::         ::::    .:::.        \033[37m              &&&X.    &&&&..    .&&&;                                 ");
	$display("\033[31m BBBBBBBBBBBi     iBBBBBL       .BBBB    7BBB7        \033[37m             &&&X .   .&&&; .    .&&&;                                 ");
	$display("\033[31m BBBB.::::ir.     BBB:BBB.      .BBBv    iBBB:        \033[37m            X&&&...   +&&&. .    ;&&&:                                 ");
	$display("\033[31m BBBQ            :BBY iBB7       BBB7    :BBB:        \033[37m           ;&&&; ..  .&&&X  .    x&&&.                                 ");
	$display("\033[31m BBBB            BBB. .BBB.      BBB7    :BBB:        \033[37m           &&&$  ..  ;&&&+  .   .&&&$                                  ");
	$display("\033[31m BBBB:r7vvj:    :BBB   gBBs      BBB7    :BBB:        \033[37m          .&&&;  ..  $&&&. ..   ;&&&;                                  ");
	$display("\033[31m BBBBBBBBBB7    BBB:   .BBB.     BBB7    :BBB:        \033[37m          ;&&&:  .  .&&&x ..    X&&&                                   ");
	$display("\033[31m BBBB    ..    iBBBBBBBBBBBP     BBB7    :BBB:        \033[37m          +&&&.  .  +&&&: ..   .&&&x                                   ");
	$display("\033[31m BBBB          BBBBi7vviQBBB.    BBB7    :BBB.        \033[37m          +&&&.     $&&X. ..   X&&&.                                   ");
	$display("\033[31m BBBB         rBBB.      BBBQ   .BBBv    iBBB2ir777L7 \033[37m          +&&&.    :&&&:...   :&&&X                                    ");
	$display("\033[31m.BBBB        :BBBB       BBBB7  .BBBB    7BBBBBBBBBBB \033[37m          ;&&&.    x&&$       X&&&.                                    ");
	$display("\033[31m . ..        ....         ...:   ....    ..   ....... \033[37m          .&&&.   .&&&&+.    :&&&X                                     ");
	$display("\033[37m                                                        :+X&&.   X&X     X&&&X.    &&&&                                      ");
	$display("\033[37m                                                    ;$&&&&&&&:                     :Xx  ;&&&&&&$;                            ");
	$display("\033[37m                                                .$&&&&&X;.                                 ;x&&&&&&+   $&&&X:                ");
	$display("\033[37m                                              ;&&&&&x.                                         :$&&&&;  ;x&&&&&:             ");
	$display("\033[37m                                            :&&&&&.      .;X$$:                   ....            ;&&&&+    .x&&&x           ");
	$display("\033[37m                                           $&&&x.     .$&&&&&&x.                ;&&&&&&&$;          :&&&&;      $&&X         ");
	$display("\033[37m                                         :&&&&.     .$&&&;.                        ..;&&&&&$.         x&&&x      :&&&.       ");
	$display("\033[37m                                        .&&&&      :&&&.                                ;&&&&:         +&&&x       $&&+      ");
	$display("\033[37m                                        $&&$.     :&&X                                   .$&&&:         ;&&&+       &&&x     ");
	$display("\033[37m                                       x&&&.     .&&x                                   .  &&&&.         $&&&:      .&&&+    ");
	$display("\033[37m                                      :&&&:       ;+.      .:;:..              :&&&&&x     :&&&.         ;&&&x       +&&&    ");
	$display("\033[37m                                      X&&$               .&&&&&&&&.           X&&& .&&&+     .           .&&&$       :&&&;   ");
	$display("\033[37m                                      &&&;               $&&& +&&&X           $&&&&&&&&x                  $&&&:       &&&&   ");
	$display("\033[37m                                     +&&&.               X&&&&&&&&;           +&&&&x&&&.             .    x&&&;       x&&&:  ");
	$display("\033[37m                                     &&&X  \033[38;2;255;192;203m      ....   \033[37m .X&&&&&&;             .x&&&&X.\033[38;2;255;192;203m  ......    \033[37m  ..   ;&&&:       +&&&+  ");
	$display("\033[37m                                     X&&X  \033[38;2;255;192;203m  .  ;&$. .. \033[37m                .              \033[38;2;255;192;203m x&&:   ..  \033[37m       +&&&.       ;&&&+  ");
	$display("\033[37m         x&&&&&&&&&&&&&&&&&X         +&&$  \033[38;2;255;192;203m .. .&&&:&&&: . \033[37m        .:..&&&;          \033[38;2;255;192;203m .+&&&.x&&: . \033[37m       x&&&        :&&&X  ");
	$display("\033[37m      :;  xxxx;   .;;;.  .$&&.       :&&&. \033[38;2;255;192;203m  . .XX.x&&;  . \033[37m       .&&&&&&&&&X;       \033[38;2;255;192;203m ..&&:.$&&&.. \033[37m      .&&&X        ;&&&x  ");
	$display("\033[37m   ;&&&&:                  x&&:       $&&$ \033[38;2;255;192;203m        .:.. .  \033[37m         +&&&;x&&&x.      \033[38;2;255;192;203m .      .:.   \033[37m      ;&&&.        ;&&&;  ");
	$display("\033[37m :&&&&&&$        .+$&&&$Xx+X&&&.       &&&X\033[38;2;255;192;203m    ........    \033[37m         .&&&+            \033[38;2;255;192;203m    .......   \033[37m     .&&&x         X&&&   ");
	$display("\033[37m &&$   +&&&&&&&&&&&&&&&&&&&&&&&;       .&&&&.                        ;&&&&.                             X&&&          &&&$   ");
	$display("\033[37m &&x:&x  $&&&&&&X.          x&&         .&&&&+                         .:.                             X&&&          .&&&;   ");
	$display("\033[37m.&&$:&&+ :&&;x&&            $&&           :&&&&;                                                     ;&&&X           x&&&    ");
	$display("\033[37m X&&&:   .&&; &&+           ;&&;             $&&$.                                                  ;&&&             &&&+    ");
	$display("\033[37m  :&&&&$$&&&&$&&&            $&&.            ;&&+                                                    .&&;           x&&&.    ");
	$display("\033[37m     x&&&&&&&&&&&;           x&&&+           $&&.     .                                   ;&&+       .&&X          :&&&+     ");
	$display("\033[37m               +&&. .+x$&&&&&&&X:            &&&.   .&&$                                 x&&X  .&$   .&&X         +&&&;      ");
	$display("\033[37m                &&&&&&&&&&&X:                &&&.   .&&;                                .&&&+ ;&&&.  ;&&&+        &&$        ");
	$display("\033[37m                 ;+:                         +&&$. +&&X                                  $&&&&&&&;   X&&&&X                  ");
	$display("\033[37m                                              :&&&&&&&+.                                 .+&&&&;    :&&&&&&.   :&$           ");
	$display("\033[37m                                                     &&&;                                          .&&&&&&&    X&&+          ");
	$display("\033[37m                                                     .&&&:                                        .&&&&&&&     &&&&          ");
	$display("\033[37m                                                      :&&&;                                      ;&&&&&&&x    x&&&x          ");
	$display("\033[37m                                                   :&x  &&&$.                                   x&&&&&&&.    $&&&&$          ");
	$display("\033[37m                                                  +&&X    x&&&&;                              x&&&&&&&x    .&&&&&&&          ");
	$display("\033[37m                                                  &&&       x&&+    +$;      ..        ..;X&&&&&&&&x.     x&&&&&&&X          ");
	$display("\033[37m                                                  $&&       .&&&   :&&&.   .$&&:&&&&&&&&&&&&&$;          &&&&X &&&;          ");
	$display("\033[37m                                                  :&&&:      +&&&;;&&&&    X&&. x&&&&&$X:             .$&&&&: ;&&&           ");
	$display("\033[37m                                                   ;&&&$      .$&&&&&&&$:X&&$                       :&&&&&:  :&&&:           ");
	$display("\033[37m                                                    .&&&&&;          X&&&&X.                     +&&&&&X    +&&&.            ");
	$display("\033[37m                                                      .$&&&&&+                               x&&&&&&+      ;&&&.             ");
	$display("\033[37m                                                         :&&&&&&&&$+.            .;+xX$&&&&&&&&&X:        +&&&:              ");
	$display("\033[37m                                                           $&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&x:           +&&&&.               ");
	$display("\033[37m                                                             x&&&&;+X&&&&&&&&&&&$x.                  :$&&&&:                 ");
	$display("\033[37m                                                               &&&&$:                             .X&&&&x                    ");
	$display("\033[37m                                                                .&&&&&&&&&&+                   X&&&&&$.                      ");
	$display("\033[37m                                                                      .;&&&&&                  $&&&+                         ");
	$display("\033[37m                                                                         &&&&+.             :x&&&&:                          ");
	$display("\033[37m                                                                          X&&&&&&&&&&&&&&&&&&&&$                             ");
	$display("\033[37m                                                                             .;xX$&&&&&$$x+:                                 ");
// light pink blush: \033[38;2;255;192;203m
// character: 125 pixels
// contrast: 185%
end endtask

endmodule