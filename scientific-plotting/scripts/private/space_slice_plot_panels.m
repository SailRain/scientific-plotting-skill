function [options, bounds] = space_slice_plot_panels(panels, options)
%SPACE_SLICE_PLOT_PANELS Fit actual rotated content around sheared frames.
index = (0:numel(panels)-1).';
column = mod(index, options.columns);
row = floor(index / options.columns);
vertical = max(row) - row;
height = options.slice_height_mm + options.slice_drop_mm;
origins = [column * (options.slice_width_mm + options.slice_gap_mm), ...
    vertical * (height + options.row_gap_mm) + options.slice_drop_mm];
extra = 0;
for i = 1:numel(panels)
    for j = i+1:min(numel(panels), i + options.columns - column(i) - 1)
        step = column(j) - column(i);
        offset = origins(j, :) - origins(i, :);
        extra = max(extra, separating_shift(panels{i}, panels{j}, offset, 1) / step);
    end
end
options.slice_gap_mm = options.slice_gap_mm + extra;
origins(:, 1) = origins(:, 1) + column * extra;
extra = 0;
for i = 1:numel(panels)-1
    next_row = (row(i) + 1) * options.columns + 1;
    for j = next_row:numel(panels)
        step = row(j) - row(i);
        offset = origins(i, :) - origins(j, :);
        extra = max(extra, separating_shift(panels{j}, panels{i}, offset, 2) / step);
    end
end
options.row_gap_mm = options.row_gap_mm + extra;
origins(:, 2) = origins(:, 2) + vertical * extra;

bounds = [Inf, Inf, -Inf, -Inf];
for i = 1:numel(panels)
    points = vertcat(panels{i}{:}) + origins(i, :);
    bounds = [min(bounds(1:2), min(points, [], 1)), max(bounds(3:4), max(points, [], 1))];
end
end

function shift = separating_shift(first, second, offset, direction)
% Clip the range of translations in which two convex shapes can intersect.
% This uses their edge normals, so diagonal labels are not treated as the
% much larger, axis-aligned rectangles that enclose them.
shift = 0;
cross = 3 - direction;
clearance = 0.10;
for a = first
    p = a{1};
    for b = second
        q = b{1} + offset;
        if max(p(:, cross)) <= min(q(:, cross)) || max(q(:, cross)) <= min(p(:, cross)) || ...
                max(p(:, direction)) + clearance <= min(q(:, direction))
            continue;
        end
        edges = [circshift(p, -1) - p; circshift(q, -1) - q];
        normal = [-edges(:, 2), edges(:, 1)];
        normal = normal(any(abs(normal) > 1e-8, 2), :);
        first_projection = p * normal.';
        second_projection = q * normal.';
        lower = min(first_projection, [], 1) - max(second_projection, [], 1);
        upper = max(first_projection, [], 1) - min(second_projection, [], 1);
        travel = normal(:, direction).';
        fixed = abs(travel) <= 1e-8;
        if any(lower(fixed) >= 0 | upper(fixed) <= 0)
            continue;
        end
        intervals = [lower(~fixed) ./ travel(~fixed); upper(~fixed) ./ travel(~fixed)];
        entry = max(min(intervals, [], 1));
        exit = min(max(intervals, [], 1));
        if entry < exit
            shift = max(shift, exit + clearance);
        end
    end
end
end
