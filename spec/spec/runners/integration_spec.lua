require 'spec.spec_helper'


describe("Integration", function()
    before_each(function()
        IntegrationRunner = require 'gin.spec.runners.integration'
    end)

    after_each(function()
        package.loaded['gin.spec.runners.integration'] = nil
        IntegrationRunner = nil
    end)

    describe(".encode_table", function()
        it("encodes a table into querystring params", function()
            args = {
                arg1 = 1.0,
                arg2 = { "two/string", "another/string" },
                ['arg~3'] = "a tag",
                [5] = "five"
            }

            local urlencoded = IntegrationRunner.encode_table(args)

            assert.are.equal(67, #urlencoded)

            local amppos = urlencoded:find("&", 6, true)
            assert.is.number(amppos)
            amppos = urlencoded:find("&", 1 + amppos, true)
            assert.is.number(amppos)
            amppos = urlencoded:find("&", 1 + amppos, true)
            assert.is.number(amppos)
            amppos = urlencoded:find("&", 1 + amppos, true)
            assert.is.number(amppos)
            assert.is_nil(urlencoded:find("&", 1 + amppos, true))

            assert.is_number(urlencoded:find("arg~3=a%20tag", 1, true))
            assert.is_number(urlencoded:find("arg2=two%2fstring", 1, true))
            assert.is_number(urlencoded:find("arg2=another%2fstring", 1, true))
            assert.is_number(urlencoded:find("5=five", 1, true))
            assert.is_number(urlencoded:find("arg1=1", 1, true))
        end)
    end)

    describe(".hit", function()
        before_each(function()
            require 'gin.cli.launcher'
            stub(package.loaded['gin.cli.launcher'], "start")
            stub(package.loaded['gin.cli.launcher'], "stop")

            require 'socket.http'
            request = nil
            package.loaded['socket.http'].request = function(...)
                request = ...
                return true, 201, { ['Some-Header'] = 'some-header-value' }
            end

            local info

            IntegrationRunner.source_for_caller_at = function(...)
                return "/controllers/1/controller_spec.lua"
            end
        end)

        after_each(function()
            package.loaded['gin.cli.launcher'] = nil
            package.loaded['socket.http'] = nil
            request = nil
        end)

        it("ensures content length is set", function()
            IntegrationRunner.hit({
                method = 'GET',
                path = "/",
                body = { name = 'gin' }
            })

            assert.are.same(14, request.headers["Content-Length"])
        end)

        it("raises an error when the caller major version cannot be retrieved", function()
            IntegrationRunner.source_for_caller_at = function(...)
                return "controller_spec.lua"
            end

            local ok, err = pcall(function()
                return IntegrationRunner.hit({
                    method = 'GET',
                    path = "/"
                })
            end)

            assert.are.equal(false, ok)
            assert.are.equal(true, string.find(err, "Could not determine API major version from controller spec file. Ensure to follow naming conventions") > 0)
        end)

        it("raises an error when the caller major version does not match the specified api_version", function()
            local ok, err = pcall(function()
                return IntegrationRunner.hit({
                    api_version = '2',
                    method = 'GET',
                    path = "/"
                })
            end)

            assert.are.equal(false, ok)
            assert.are.equal(true, string.find(err, "Specified API version 2 does not match controller spec namespace %(1%)") > 0)
        end)

        describe("Accept header", function()
            describe("when no api_version is specified", function()
                it("sets the accept header from the namespace", function()
                    local response = IntegrationRunner.hit({
                        method = 'GET',
                        path = "/"
                    })

                    assert.are.same("application/vnd.ginapp.v1+json", request.headers["Accept"])
                end)
            end)

            describe("when a specifid api_version is specified", function()
                it("sets the accept header from the namespace", function()
                    local response = IntegrationRunner.hit({
                        api_version = '1.2.3-p247',
                        method = 'GET',
                        path = "/"
                    })

                    assert.are.same("application/vnd.ginapp.v1.2.3-p247+json", request.headers["Accept"])
                end)
            end)
        end)

        it("calls the server with the correct parameters", function()
            local request_body_arg
            ltn12.source.string = function(request_body)
                request_body_arg = request_body
                return request_body
            end

            local request_body_arg
            ltn12.sink.table = function(request_body)
                request_body_arg = request_body
                return request_body
            end

            IntegrationRunner.hit({
                method = 'GET',
                path = "/",
                headers = { ['Test-Header'] = 'test-header-value' },
                body = { name = 'gin' }
            })

            assert.are.equal("http://127.0.0.1:7201/?", request.url)
            assert.are.equal('GET', request.method)
            assert.are.same('test-header-value', request.headers['Test-Header'])
            assert.are.same('{"name":"gin"}', request.source)
            assert.are.same(request_body_arg, request.sink)
        end)

        it("returns a ResponseSpec", function()
            local response = IntegrationRunner.hit({
                method = 'GET',
                path = "/"
            })

            assert.are.equal(201, response.status)
            assert.are.same({ ['Some-Header'] = 'some-header-value' }, response.headers)
        end)
    end)
end)
