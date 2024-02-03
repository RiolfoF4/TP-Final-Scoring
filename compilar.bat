if not exist "\comp\" mkdir comp
if not exist "\archivo\" mkdir archivo
fpc .\scoring.pas -FUcomp -O2