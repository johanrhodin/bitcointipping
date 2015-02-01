(* ::Package:: *)

(*Constants*)
(*myadr = " "; *)(*Example: "1HxhvPBGuUTiu9n1sV78epGrcGTPujdDB3";*)
(*chainapikey = " ";*) (*Insert API key from Chain.com*)
(*Or store them in a credentials file*)
Get["~/bitcointipping/credentials.m"];

(*Load the lcdlink*)
<<"!gpio load i2c"
SetDirectory["~/rpi-lcdlink"]
lcdlink = Install["lcdlink"];
lcdClear[];
lcdPuts["Bitcoin tipping starting..."];
SetDirectory["~/bitcointipping"];

str = "https://api.chain.com/v2/bitcoin/addresses/"<>myadr<>"/transactions?api-key-id="<>chainapikey<>"&limit=10";
sndfile = "~/bitcointipping/assets/coins-drop-1.wav";
(*Let all previous transactions be new*)
oldhashes={};
pattern=If[$OperatingSystem==="MacOSX",
	{__,Verbatim["addresses"->{myadr}],__,HoldPattern["value"->y_],__}:> y,
	(*Raspberry Pi / UNIX*)
	{__,HoldPattern["value" -> y_],__, Verbatim["addresses" -> {myadr}], __}:> y];

(*Run loop*)
RunScheduledTask[
 data = Quiet[ImportString[URLFetch[str],"JSON"]];
 hashes = "hash" /. data;
 nrNewTransactions = Length[Complement[hashes, oldhashes]];
 If[nrNewTransactions > 0, 
  outputs = "outputs" /. data[[1 ;; nrNewTransactions]]; 
  newtransactions = 
   Cases[outputs, pattern, Infinity];
  (*Play coin sound*)
  Quiet@Run["aplay "<> sndfile];
	lcdClear[];
  If[nrNewTransactions == 1,
	onetransactionstr=ToString[First[newtransactions]] <> " satoshis tippped at " <>
      DateString[{"Hour",":","Minute"},TimeZone->$TimeZone];
	Print[onetransactionstr];
	lcdPuts[onetransactionstr],
	manytransstr=StringJoin[Riffle[ToString /@ newtransactions, " and "]] <> 
     " satoshis tipped at " <> DateString[{"Hour",":","Minute"},TimeZone->$TimeZone];
	Print[manytransstr];
	lcdPuts[manytransstr];
	]
 ];
 (*Set the old hashes to include new hashes*)
 oldhashes = hashes;
 ,60
 ];
