function CodeBlock(block)
    if (block.classes:includes('{md-demo}') or
        block.classes:includes('md-demo')) then
        return { pandoc.Div(
            markdown_block(block.text),
            pandoc.Attr('', { "md-code" })
        ),
        pandoc.Div(
            pandoc.read(block.text).blocks,
            pandoc.Attr('', { "md-render" })
        ) }
    end
end

function Div(div)
    if div.classes:includes('qmd-demo') then
        -- get any before/after content in the columns
        local bc1 = find_div(div.content, "before-col1")
        local ac1 = find_div(div.content, "after-col1")
        local bc2 = find_div(div.content, "before-col2")
        local ac2 = find_div(div.content, "after-col2")

        local basename = div.attributes["file"]
        local basedir = "_static/qmd_"
        local qmd_file = basedir .. "code/" .. basename .. ".qmd"
        local qmd_path = quarto.utils.resolve_path(qmd_file)
        local html_file = '../' .. basedir .. "render/" .. basename .. ".html"
        local file = io.open(qmd_path)
        assert(file)
        local content = file:read("*a")

        local ol
        if ac1.content[1].t == "OrderedList" then
            ol = ac1.content[1]
            ac1.content:remove(1)
        else
            ol = pandoc.Div("")
        end

        return columns(
            { bc1, markdown_block(content), ol, ac1 },
            { bc2, iframe(html_file), ac2 }
        )
    end
end

function markdown_block(text)
    return pandoc.CodeBlock(
            text,
            pandoc.Attr('', { '.markdown' })
    )
end

function columns(block1, block2) 
    c1 = classed_div(block1, { "col-7" })
    -- c1.attributes["width"] = "60%"
    c2 = classed_div(block2, { "col-5" })
    -- c2.attributes["width"] = "40%"
    return classed_div(
        classed_div({ c1, c2 }, { "row", "qmd-demo" }), 
        { "container-fluid" })
end

function classed_div(content, classes)
    return pandoc.Div(
        content,
        pandoc.Attr('', classes)
    )
end
    
function iframe(src)
    return pandoc.RawBlock('html',
        '<iframe src="' .. 
        src .. 
        '" ' ..
        'class="qmd-demo-render">' ..
        '</iframe>')
end

function find_div(table, class_name)
    for i = 1, #table do
        local el = table[i]
        if el.t == "Div" and el.classes:includes(class_name) then
            return el
        end
    end
    return pandoc.Div("", pandoc.Attr('', { class_name }))
end