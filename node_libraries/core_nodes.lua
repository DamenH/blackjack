local function scalar(name, default, min, max)
    return {
        name = name,
        default = default,
        min = min,
        max = max,
        type = "scalar"
    }
end
local function v3(name, default)
    return {name = name, default = default, type = "vec3"}
end
local function mesh(name) return {name = name, type = "mesh"} end
local function selection(name) return {name = name, type = "selection"} end
local function enum(name, values, selected)
    return {
        name = name,
        type = "enum",
        values = values or {},
        selected = selected
    }
end
local function file(name) return {name = name, type = "file"} end

local core_nodes = {
    MakeBox = {
        label = "Box",
        op = function(inputs)
            return {out_mesh = Primitives.cube(inputs.origin, inputs.size)}
        end,
        inputs = {v3("origin", Vec3(0, 0, 0)), v3("size", Vec3(1, 1, 1))},
        outputs = {mesh("out_mesh")},
        returns = "out_mesh"
    },
    MakeQuad = {
        label = "Quad",
        op = function(inputs)
            return {
                out_mesh = Primitives.quad(inputs.center, inputs.normal,
                                           inputs.right, inputs.size)
            }
        end,
        inputs = {
            v3("center", Vec3(0, 0, 0)), v3("normal", Vec3(0, 1, 0)),
            v3("right", Vec3(1, 0, 0)), v3("size", Vec3(1, 1, 1))
        },
        outputs = {mesh("out_mesh")},
        returns = "out_mesh"
    },
    BevelEdges = {
        label = "Bevel edges",
        inputs = {
            mesh("in_mesh"), selection("edges"), scalar("amount", 0.0, 0.0, 1.0)
        },
        outputs = {mesh("out_mesh")},
        returns = "out_mesh",
        op = function(inputs)
            return {
                out_mesh = Ops.bevel(inputs.edges, inputs.amount, inputs.in_mesh)
            }
        end
    },
    ChamferVertices = {
        label = "Chamfer vertices",
        inputs = {
            mesh("in_mesh"), selection("vertices"),
            scalar("amount", 0.0, 0.0, 1.0)
        },
        outputs = {mesh("out_mesh")},
        returns = "out_mesh",
        op = function(inputs)
            return {
                out_mesh = Ops.chamfer(inputs.vertices, inputs.amount,
                                       inputs.in_mesh)
            }
        end
    },
    ExtrudeFaces = {
        label = "Extrude faces",
        inputs = {
            mesh("in_mesh"), selection("faces"), scalar("amount", 0.0, 0.0, 1.0)
        },
        outputs = {mesh("out_mesh")},
        returns = "out_mesh",
        op = function(inputs)
            return {
                out_mesh = Ops.extrude(inputs.faces, inputs.amount,
                                       inputs.in_mesh)
            }
        end
    },
    MakeVector = {
        label = "MakeVector",
        inputs = {
            scalar("x", 0.0, -100.0, 100.0), scalar("y", 0.0, -100.0, 100.0),
            scalar("z", 0.0, -100.0, 100.0)
        },
        outputs = {v3("v")},
        op = function(inputs)
            return {v = Vec3(inputs.x, inputs.y, inputs.z)}
        end
    },
    VectorMath = {
        label = "Vector math",
        inputs = {
            enum("op", {"Add", "Sub", "Mul"}, 0), v3("vec_a", Vec3(0, 0, 0)),
            v3("vec_b", Vec3(0, 0, 0))
        },
        outputs = {v3("out")},
        op = function(inputs)
            local out
            if inputs.op == "Add" then
                out = inputs.vec_a + inputs.vec_b
            elseif inputs.op == "Sub" then
                out = inputs.vec_a - inputs.vec_b
            elseif inputs.op == "Mul" then
                out = inputs.vec_a * inputs.vec_b
            end
            return {out = out}
        end
    },
    MergeMeshes = {
        label = "Merge meshes",
        inputs = {mesh("mesh_a"), mesh("mesh_b")},
        outputs = {mesh("out_mesh")},
        returns = "out_mesh",
        op = function(inputs)
            return {out_mesh = Ops.merge(inputs.mesh_a, inputs.mesh_b)}
        end
    },
    ExportObj = {
        label = "Export obj",
        inputs = {mesh("mesh"), file("path")},
        outputs = {},
        executable = true,
        op = function(inputs)
            Export.wavefront_obj(inputs.mesh, inputs.path)
        end
    },
    Subdivide = {
        label = "Subdivide",
        inputs = {
            mesh("mesh"), enum("technique", {"linear", "catmull-clark"}, 0),
            scalar("iterations", 1, 1, 7)
        },
        outputs = {mesh("out_mesh")},
        returns = "out_mesh",
        op = function(inputs)
            return {
                out_mesh = Ops.subdivide(inputs.mesh, inputs.iterations,
                                         inputs.technique == "catmull-clark")
            }
        end
    }

}

NodeLibrary:addNodes(core_nodes)