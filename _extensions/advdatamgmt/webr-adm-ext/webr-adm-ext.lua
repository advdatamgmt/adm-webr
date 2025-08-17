-- Load `r-wasm/live/live.lua` helpers from the installed extension in a
-- sandboxed environment.
local function load_r_wasm_helpers()
  local rwasm = quarto.utils.resolve_path("../../r-wasm/live/live.lua")

  -- Make a sandbox env with access to core globals Quarto/Pandoc APIs
  local live_env = {
    quarto = quarto,
    pandoc = pandoc,
  }

  -- add fallback to globals
  setmetatable(live_env, {
    __index = _G,
  })

  local function load_chunk_with_env(path, env)
    local fh, ferr = io.open(path, "r")
    if not fh then return nil, ferr end
    local src = fh:read("*a")
    fh:close()

    local chunk, err = load(src, "@" .. path, "t", env)
    return chunk, err
  end

  local chunk, err = load_chunk_with_env(rwasm, live_env)
  if not chunk then
    if quarto and quarto.log then
      quarto.log.error("Could not load r-wasm live.lua: " .. tostring(err))
    end
    return {}
  end

  local ok, exec_err = pcall(chunk)
  if not ok then
    if quarto and quarto.log then
      quarto.log.error("Error executing r-wasm live.lua: " .. tostring(exec_err))
    end
    return {}
  end

  return live_env
end

local live = load_r_wasm_helpers()
local ParseBlock = live.ParseBlock

function CodeBlock(block)
  if (
        block.classes:includes('{adm}') or
        block.classes:includes('adm')
      ) then
      return AdmCodeBlock(block)
  end
end

function AdmCodeBlock(block)
  -- NOTE: without _knitr.qmd included knitr will strip the comments
  -- from the code blocks with {}'d language, but not those with the
  -- language bare text
  local pblock = ParseBlock(block, "webr")

  local file = io.open(
    quarto.utils.resolve_path("templates/" ..
      pblock.attr.type .. ".html")
  )
  assert(file)
  local content = file:read("*a")

  for k, v in pairs(pblock.attr) do
    content = string.gsub(
      content,
      "%$%$" .. k .. "%$%$",
      tostring(v)
    )
  end

  quarto.doc.include_text("after-body", content)

  out = pandoc.Div(
    pandoc.read(pblock.code).blocks,
    pandoc.Attr(
      "open-on-pass-" .. pblock.attr.exercise,
      { 'webr-adm-ext' },
      { style = 'visibility: hidden;' }
    )
  )
  return out
end
