for /R %%v in (*.lua) do gmodluacompiler "%%v" "%%v.windows64.protected" "1"
PAUSE