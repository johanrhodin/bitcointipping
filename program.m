(*Constants*)
myadr = (*Example: "1HxhvPBGuUTiu9n1sV78epGrcGTPujdDB3";*)
tmpfile = FileNameJoin[{$TemporaryDirectory, "transactions.json"}];
chainapikey= ""; (*Insert API key from Chain.com*)
str = "curl -o " <> tmpfile <> 
   " 'https://api.chain.com/v2/bitcoin/addresses/"<>myadr<>"/transactions?api-key-id=\
"<>chainapikey>"?&limit=10'";
oldhashes="3c7cc526a1f808eb5349b07a49828ad8c1d7d9fe76a8130e6a5885ee9cc9c6b7";

(*Run loop*)
Do[Quiet[Run[str]];
 data = Quiet[Import[tmpfile]];
 hashes = "hash" /. data;
 nrNewTransactions = Length[Complement[hashes, oldhashes]];
 If[nrNewTransactions > 0, 
  outputs = "outputs" /. data[[1 ;; nrNewTransactions]]; 
  newtransactions = 
   Cases[outputs, {__, Verbatim["addresses" -> {myadr}], __, 
      HoldPattern["value" -> y_], __} :> y, Infinity];
  (*Play coin sound*)
  Quiet@Run["aplay /home/pi/coins-drop-1.wav"];
  If[nrNewTransactions == 1, 
   Print[ToString[newtransactions] <> " satoshis tippped at " <>
      DateString[]], 
   Print[StringJoin[Riffle[ToString /@ newtransactions, " and "]] <> 
     " satoshis tipped at" <> DateString[]]];
  ];
 (*Set the old hashes to include new hashes*)
 oldhashes = hashes;
 Pause[60],
 {600}
 ]