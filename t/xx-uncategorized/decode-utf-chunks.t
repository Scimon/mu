use v6-alpha;


=pod

Pugs' translation of UTF-8 into unicode strings works in 4k chunks,
as benchmarks have shown this to be fastest.

Unfortunately, unless a chunk ends in on a character boundary, the last
code point to be decoded in a chunk will fail, until the decoder is
fixed to carry untreated bytes over to the next chunk.

The plan: check a long string literal for integrity. To battle
Murphy viz. different lineendings, characters represented by three
bytes is used, and the string is very long indeed.

=cut

use Test;

plan 69;

# relegated to a funciton so that the long literal can come near the end
my $long = get_long();

my $small_chunk = 128;       # reasonable chunk length
my $chunk_count = 68;        # a little over 8k of data
my $offset      = 0xdd00;

is $long.chars, $small_chunk * $chunk_count,
       "literal has correct character count";

for 0 ..^ $chunk_count -> $chunk {
    is (substr $long, $chunk * $small_chunk, $small_chunk),
        ([~] map { chr $_ + $offset }, $chunk * $small_chunk ..^
                (($chunk + 1) * $small_chunk)),
        "chunk #$chunk";
}

sub get_long {
    "������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������豈更車賈滑串句龜龜契金喇奈懶癩羅蘿螺裸邏樂洛烙珞落酪駱亂卵欄爛蘭鸞嵐濫藍襤拉臘蠟廊朗浪狼郎來冷勞擄櫓爐盧老蘆虜路露魯鷺碌祿綠菉錄鹿論壟弄籠聾牢磊賂雷壘屢樓淚漏累縷陋勒肋凜凌稜綾菱陵讀拏樂諾丹寧怒率異北磻便復不泌數索參塞省葉說殺辰沈拾若掠略亮兩凉梁糧良諒量勵呂女廬旅濾礪閭驪麗黎力曆歷轢年憐戀撚漣煉璉秊練聯輦蓮連鍊列劣咽烈裂說廉念捻殮簾獵令囹寧嶺怜玲瑩羚聆鈴零靈領例禮醴隸惡了僚寮尿料樂燎療蓼遼龍暈阮劉杻柳流溜琉留硫紐類六戮陸倫崙淪輪律慄栗率隆利吏履易李梨泥理痢罹裏裡里離匿溺吝燐璘藺隣鱗麟林淋臨立笠粒狀炙識什茶刺切度拓糖宅洞暴輻行降見廓兀嗀﨎﨏塚﨑晴﨓﨔凞猪益礼神祥福靖精羽﨟蘒﨡諸﨣﨤逸都﨧﨨﨩飯飼館鶴郞隷侮僧免勉勤卑喝嘆器塀墨層屮悔慨憎懲敏既暑梅海渚漢煮爫琢碑社祉祈祐祖祝禍禎穀突節練縉繁署者臭艹艹著褐視謁謹賓贈辶逸難響頻恵𤋮舘﩮﩯並况全侀充冀勇勺喝啕喙嗢塚墳奄奔婢嬨廒廙彩徭惘慎愈憎慠懲戴揄搜摒敖晴朗望杖歹殺流滛滋漢瀞煮瞧爵犯猪瑱甆画瘝瘟益盛直睊着磌窱節类絛練缾者荒華蝹襁覆視調諸請謁諾諭謹變贈輸遲醙鉶陼難靖韛響頋頻鬒龜𢡊𢡄𣏕㮝䀘䀹𥉉𥳐𧻓齃龎﫚﫛﫜﫝﫞﫟﫠﫡﫢﫣﫤﫥﫦﫧﫨﫩﫪﫫﫬﫭﫮﫯﫰﫱﫲﫳﫴﫵﫶﫷﫸﫹﫺﫻﫼﫽﫾﫿ﬀﬁﬂﬃﬄﬅﬆ﬇﬈﬉﬊﬋﬌﬍﬎﬏﬐﬑﬒ﬓﬔﬕﬖﬗ﬘﬙﬚﬛﬜יִﬞײַﬠﬡﬢﬣﬤﬥﬦﬧﬨ﬩שׁשׂשּׁשּׂאַאָאּבּגּדּהּוּזּ﬷טּיּךּכּלּ﬽מּ﬿נּסּ﭂ףּפּ﭅צּקּרּשּתּוֹבֿכֿפֿﭏﭐﭑﭒﭓﭔﭕﭖﭗﭘﭙﭚﭛﭜﭝﭞﭟﭠﭡﭢﭣﭤﭥﭦﭧﭨﭩﭪﭫﭬﭭﭮﭯﭰﭱﭲﭳﭴﭵﭶﭷﭸﭹﭺﭻﭼﭽﭾﭿﮀﮁﮂﮃﮄﮅﮆﮇﮈﮉﮊﮋﮌﮍﮎﮏﮐﮑﮒﮓﮔﮕﮖﮗﮘﮙﮚﮛﮜﮝﮞﮟﮠﮡﮢﮣﮤﮥﮦﮧﮨﮩﮪﮫﮬﮭﮮﮯﮰﮱ﮲﮳﮴﮵﮶﮷﮸﮹﮺﮻﮼﮽﮾﮿﯀﯁﯂﯃﯄﯅﯆﯇﯈﯉﯊﯋﯌﯍﯎﯏﯐﯑﯒ﯓﯔﯕﯖﯗﯘﯙﯚﯛﯜﯝﯞﯟﯠﯡﯢﯣﯤﯥﯦﯧﯨﯩﯪﯫﯬﯭﯮﯯﯰﯱﯲﯳﯴﯵﯶﯷﯸﯹﯺﯻﯼﯽﯾﯿﰀﰁﰂﰃﰄﰅﰆﰇﰈﰉﰊﰋﰌﰍﰎﰏﰐﰑﰒﰓﰔﰕﰖﰗﰘﰙﰚﰛﰜﰝﰞﰟﰠﰡﰢﰣﰤﰥﰦﰧﰨﰩﰪﰫﰬﰭﰮﰯﰰﰱﰲﰳﰴﰵﰶﰷﰸﰹﰺﰻﰼﰽﰾﰿﱀﱁﱂﱃﱄﱅﱆﱇﱈﱉﱊﱋﱌﱍﱎﱏﱐﱑﱒﱓﱔﱕﱖﱗﱘﱙﱚﱛﱜﱝﱞﱟﱠﱡﱢﱣﱤﱥﱦﱧﱨﱩﱪﱫﱬﱭﱮﱯﱰﱱﱲﱳﱴﱵﱶﱷﱸﱹﱺﱻﱼﱽﱾﱿﲀﲁﲂﲃﲄﲅﲆﲇﲈﲉﲊﲋﲌﲍﲎﲏﲐﲑﲒﲓﲔﲕﲖﲗﲘﲙﲚﲛﲜﲝﲞﲟﲠﲡﲢﲣﲤﲥﲦﲧﲨﲩﲪﲫﲬﲭﲮﲯﲰﲱﲲﲳﲴﲵﲶﲷﲸﲹﲺﲻﲼﲽﲾﲿﳀﳁﳂﳃﳄﳅﳆﳇﳈﳉﳊﳋﳌﳍﳎﳏﳐﳑﳒﳓﳔﳕﳖﳗﳘﳙﳚﳛﳜﳝﳞﳟﳠﳡﳢﳣﳤﳥﳦﳧﳨﳩﳪﳫﳬﳭﳮﳯﳰﳱﳲﳳﳴﳵﳶﳷﳸﳹﳺﳻﳼﳽﳾﳿﴀﴁﴂﴃﴄﴅﴆﴇﴈﴉﴊﴋﴌﴍﴎﴏﴐﴑﴒﴓﴔﴕﴖﴗﴘﴙﴚﴛﴜﴝﴞﴟﴠﴡﴢﴣﴤﴥﴦﴧﴨﴩﴪﴫﴬﴭﴮﴯﴰﴱﴲﴳﴴﴵﴶﴷﴸﴹﴺﴻﴼﴽ﴾﴿﵀﵁﵂﵃﵄﵅﵆﵇﵈﵉﵊﵋﵌﵍﵎﵏ﵐﵑﵒﵓﵔﵕﵖﵗﵘﵙﵚﵛﵜﵝﵞﵟﵠﵡﵢﵣﵤﵥﵦﵧﵨﵩﵪﵫﵬﵭﵮﵯﵰﵱﵲﵳﵴﵵﵶﵷﵸﵹﵺﵻﵼﵽﵾﵿﶀﶁﶂﶃﶄﶅﶆﶇﶈﶉﶊﶋﶌﶍﶎﶏ﶐﶑ﶒﶓﶔﶕﶖﶗﶘﶙﶚﶛﶜﶝﶞﶟﶠﶡﶢﶣﶤﶥﶦﶧﶨﶩﶪﶫﶬﶭﶮﶯﶰﶱﶲﶳﶴﶵﶶﶷﶸﶹﶺﶻﶼﶽﶾﶿﷀﷁﷂﷃﷄﷅﷆﷇ﷈﷉﷊﷋﷌﷍﷎﷏﷐﷑﷒﷓﷔﷕﷖﷗﷘﷙﷚﷛﷜﷝﷞﷟﷠﷡﷢﷣﷤﷥﷦﷧﷨﷩﷪﷫﷬﷭﷮﷯ﷰﷱﷲﷳﷴﷵﷶﷷﷸﷹﷺﷻ﷼﷽﷾﷿︀︁︂︃︄︅︆︇︈︉︊︋︌︍︎️︐︑︒︓︔︕︖︗︘︙︚︛︜︝︞︟︧︨︩︪︫︬︭︠︡︢︣︤︥︦︮︯︰︱︲︳︴︵︶︷︸︹︺︻︼︽︾︿﹀﹁﹂﹃﹄﹅﹆﹇﹈﹉﹊﹋﹌﹍﹎﹏﹐﹑﹒﹓﹔﹕﹖﹗﹘﹙﹚﹛﹜﹝﹞﹟﹠﹡﹢﹣﹤﹥﹦﹧﹨﹩﹪﹫﹬﹭﹮﹯ﹰﹱﹲﹳﹴ﹵ﹶﹷﹸﹹﹺﹻﹼﹽﹾﹿﺀﺁﺂﺃﺄﺅﺆﺇﺈﺉﺊﺋﺌﺍﺎﺏﺐﺑﺒﺓﺔﺕﺖﺗﺘﺙﺚﺛﺜﺝﺞﺟﺠﺡﺢﺣﺤﺥﺦﺧﺨﺩﺪﺫﺬﺭﺮﺯﺰﺱﺲﺳﺴﺵﺶﺷﺸﺹﺺﺻﺼﺽﺾﺿﻀﻁﻂﻃﻄﻅﻆﻇﻈﻉﻊﻋﻌﻍﻎﻏﻐﻑﻒﻓﻔﻕﻖﻗﻘﻙﻚﻛﻜﻝﻞﻟﻠﻡﻢﻣﻤﻥﻦﻧﻨﻩﻪﻫﻬﻭﻮﻯﻰﻱﻲﻳﻴﻵﻶﻷﻸﻹﻺﻻﻼ﻽﻾﻿"
}

