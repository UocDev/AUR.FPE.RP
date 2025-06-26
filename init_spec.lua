-- Basic test suite using Busted

describe("Basic Lua test suite", function()

  it("should add two numbers correctly", function()
    local sum = 2 + 3
    assert.are.equal(5, sum)
  end)

  it("should treat strings properly", function()
    local str = "Lua" .. " is great"
    assert.are.same("Lua is great", str)
  end)

  it("should detect a failing case (example)", function()
    assert.is_false(false)
  end)

end)
