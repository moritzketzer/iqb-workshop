--- custom-vars.lua
--- Generic filter: reads a "css-vars" map from YAML front matter and injects
--- a <style> block setting CSS custom properties on :root.
---
--- Usage in YAML:
---   css-vars:
---     citation-lower-left-size: "1rem"
---     my-accent-color: "#ff0000"
---
--- These become:
---   :root { --citation-lower-left-size: 1rem; --my-accent-color: #ff0000; }
---
--- In CSS, reference them with var(--name, default):
---   font-size: var(--citation-lower-left-size, 0.75rem);

local vars = {}

function Meta(meta)
  local cv = meta["css-vars"]
  if cv then
    for k, v in pairs(cv) do
      vars["--" .. k] = pandoc.utils.stringify(v)
    end
  end
end

function Pandoc(doc)
  if next(vars) == nil then return nil end
  local parts = {}
  for k, v in pairs(vars) do
    table.insert(parts, k .. ": " .. v .. ";")
  end
  local css = "<style>:root { " .. table.concat(parts, " ") .. " }</style>"

  -- Inject into header-includes (→ <head>) instead of body blocks,
  -- because Reveal.js treats any body content before the first heading
  -- as a separate (empty) slide.
  local includes = doc.meta["header-includes"] or pandoc.MetaList({})
  if includes.t ~= "MetaList" then
    includes = pandoc.MetaList({includes})
  end
  includes:insert(pandoc.MetaBlocks({pandoc.RawBlock("html", css)}))
  doc.meta["header-includes"] = includes
  return doc
end
