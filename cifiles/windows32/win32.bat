for /R %%v in (*.lua) do gmodluacompiler "%%v" "%%v.windows32.protected" "1"
PAUSE