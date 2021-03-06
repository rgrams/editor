
local M = {}

M.zoomRate = 0.1

M.roundAllNumbersTo = 0.001
M.translateSnapIncrement = 4

M.doubleClickTime = 0.2

M.viewportBackgroundColor = {0.1, 0.1, 0.1}
M.gridColor = { 0.5, 0.5, 0.5, 0.1 }
M.bigGridColor = { 0.5, 0.5, 0.5, 0.28 }
M.gridNumberColor = { 0.7, 0.7, 0.7, 0.5 }
M.xAxisColor = { 0.8, 0.4, 0.4, 0.6 }
M.yAxisColor = { 0.4, 0.8, 0.4, 0.6 }

M.filesIndentSize = 10

M.ObjectHitRadius = 10
M.hoverHighlightColor = {1, 0.9, 0.8, 0.4}
M.selectedHighlightColor = {0.9, 0.5, 0.0, 0.9}
M.latestSelectedHighlightColor = {1, 0.9, 0.45, 1}
M.highlightLineWidth = 3
M.highlightPadding = 1
M.selectionOutOfBoundsMarkerMargin = 4
M.selectionOutOfBoundsMarkerLength = 10
M.selectionOutOfBoundsMarkerWidth = 5
M.parenthoodLineColor = {0, 1, 1, 0.3}
M.parentLineArrowAngle = 0.4
M.parentLineArrowLength = 20

return M
