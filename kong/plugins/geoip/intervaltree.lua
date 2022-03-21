-- simple implementation of an interval tree
-- used for fast numeric point/range intersect queries
-- todo: add rebalancing logic

local interval_tree = {}

function interval_tree:node(low_val, high_val)
	low_val = tonumber(low_val)
	high_val = tonumber(high_val)
	return { low_val = low_val, high_val = high_val, max_val = high_val, left_node = nil, right_node = nil}
end

function interval_tree:insert(tree, node)
	if tree == nil or tree.low_val == nil then
		return node
	else
		if tree.low_val > node.low_val then
			tree.left_node = interval_tree:insert(tree.left_node, node)
		else
			tree.right_node = interval_tree:insert(tree.right_node, node)
		end
		if node.high_val > tree.max_val then
			tree.max_val = node.high_val
		end
		return tree
	end
end

function interval_tree:point_intersects(tree, val)
	local n = interval_tree:node(val, val)
	return interval_tree:intersects(tree, n)
end

function interval_tree:intersects(tree, node)
	if tree == nil or (tree.low_val == nil and tree.high_val == nil) then
		return false
	elseif (tree.low_val <= node.high_val) and (tree.high_val >= node.low_val) then
		return true
	else
		if tree.left_node == nil or tree.left_node.max_val < node.low_val then
			return interval_tree:intersects(tree.right_node, node)
		else
			return interval_tree:intersects(tree.left_node, node)
		end
	end
end

return interval_tree