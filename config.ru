app = proc do |env|
    return [200, { "Content-Type" => "text/html" }, "hello world"]
end
run app