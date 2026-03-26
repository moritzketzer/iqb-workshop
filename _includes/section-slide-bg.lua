--- section-slide-bg.lua
--- 1. Adds `data-background-color` to slides with `.section-slide` (H1 and H2).
--- 2. Expands color tokens in `background-color` attributes: write a token name
---    (e.g. "teal") and it gets replaced with the hex value from metadata.
---    Tokens are defined in YAML: `color-tokens: { teal: "#107895", ... }`
--- 3. Handles `background-size="contain-padded[-N]"`: keeps the image in
---    RevealJS's native background layer but marks the slide so a JS
---    snippet can add padding to the actual background element at runtime.
---    Syntax: "contain-padded" (default 3%) or "contain-padded-N" (N%).
--- 4. Injects the JS snippet once (via Pandoc) when any slide uses it.
---
--- Uses a two-pass filter: pass 1 reads metadata, pass 2 processes headers.
--- This avoids the typewise traversal ordering issue where Header would run
--- before Meta, leaving section_bg as nil.

local section_bg = "#107895"
local color_tokens = {}
local needs_js = false

return {
  -- Pass 1: read metadata
  {
    Meta = function(meta)
      if meta["section-slide-bg"] then
        section_bg = pandoc.utils.stringify(meta["section-slide-bg"])
      end
      if meta["color-tokens"] then
        for k, v in pairs(meta["color-tokens"]) do
          color_tokens[k] = pandoc.utils.stringify(v)
        end
      end
    end
  },
  -- Pass 2: process headers and inject JS
  {
    Header = function(el)
      -- Expand color tokens in background-color
      local bg = el.attributes["background-color"]
      local token_expanded = false
      if bg and color_tokens[bg] then
        el.attributes["background-color"] = color_tokens[bg]
        token_expanded = true
      end

      -- contain-padded: keep native background, add data attribute for JS
      local bs = el.attributes["background-size"] or ""
      local pad = bs:match("^contain%-padded%-(%d+)$")
      local is_padded = (bs == "contain-padded") or (pad ~= nil)

      if is_padded then
        local pct = tonumber(pad) or 3
        el.attributes["background-size"] = "contain"
        el.attributes["data-bg-padding"] = tostring(pct)
        needs_js = true

        -- Still process section-slide on this header if applicable
        for _, c in ipairs(el.classes) do
          if c == "section-slide" then
            el.attributes["background-color"] = section_bg
            break
          end
        end

        return el
      end

      -- section-slide background color (H1 and H2)
      for _, c in ipairs(el.classes) do
        if c == "section-slide" then
          el.attributes["background-color"] = section_bg
          return el
        end
      end

      if token_expanded then return el end
      return nil
    end,

    Pandoc = function(doc)
      if not needs_js then return nil end

      local js = [[
<script>
// contain-padded: apply padding to RevealJS background elements.
// Matches slide sections to their background elements by DOM order.
(function() {
  function applyBgPadding() {
    var topSections = document.querySelectorAll('.reveal .slides > section');
    var topBgs = document.querySelectorAll('.reveal .backgrounds > .slide-background');

    topSections.forEach(function(outer, h) {
      var inner = outer.querySelectorAll(':scope > section');
      var bgOuter = topBgs[h];
      if (!bgOuter) return;

      if (inner.length === 0) {
        pad(outer, bgOuter);
      } else {
        var innerBgs = bgOuter.querySelectorAll(':scope > .slide-background');
        inner.forEach(function(sec, v) { pad(sec, innerBgs[v]); });
      }
    });
  }

  function pad(section, bg) {
    if (!section.dataset.bgPadding || !bg) return;
    var el = bg.querySelector('.slide-background-content');
    if (!el) return;
    el.style.padding = section.dataset.bgPadding + '%';
    el.style.backgroundOrigin = 'content-box';
    el.style.boxSizing = 'border-box';
  }

  function init() {
    if (typeof Reveal !== 'undefined' && Reveal.isReady()) {
      applyBgPadding();
    } else if (typeof Reveal !== 'undefined') {
      Reveal.on('ready', applyBgPadding);
    } else {
      setTimeout(init, 100);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
</script>
]]
      doc.blocks:insert(pandoc.RawBlock("html", js))
      return doc
    end
  }
}
