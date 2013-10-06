-- ensure a global Errors is defined
Errors = Errors or {}

-- controller helper to generate errors
function raise_error(code)
    error({ code = code })
end
