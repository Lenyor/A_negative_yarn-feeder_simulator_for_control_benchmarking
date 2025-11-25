function visualizeAlarms(t, yarn_accumulation, yarn_supply_finished, yLimits, ...
    simplified_visualization)
color_alpha = 0.5;
color_yarn_accumulation = 'red';
color_yarn_supply_finished = 'yellow';

if any(yarn_accumulation)
    if simplified_visualization
        stem(t, yarn_accumulation .* yLimits(2)/5, ...
            "filled", 'LineWidth', 0.5, 'Color', color_yarn_accumulation)
    else
        upper_curve = nan(size(yarn_accumulation));
        lower_curve = nan(size(yarn_accumulation));
        for i = 1 : length(yarn_accumulation)
            if yarn_accumulation(i) == 1
                upper_curve(i) = yLimits(2);
                lower_curve(i) = yLimits(1);
            else
                upper_curve(i) = 0;
                lower_curve(i) = 0;
            end
        end

        hold on
        fill([t' fliplr(t')], ...
            [lower_curve' fliplr(upper_curve')], ...
            color_yarn_accumulation, ...
            'EdgeColor', 'none', ...
            'FaceAlpha', color_alpha)
    end
end

if any(yarn_supply_finished)
    if simplified_visualization
        stem(t, yarn_supply_finished .* yLimits(2)/5, ...
            "filled", 'LineWidth', 0.5, 'Color', color_yarn_supply_finished)
    else
        upper_curve = nan(size(yarn_supply_finished));
        lower_curve = nan(size(yarn_supply_finished));
        for i = 1 : length(yarn_supply_finished)
            if yarn_supply_finished(i) == 1
                upper_curve(i) = yLimits(2);
                lower_curve(i) = yLimits(1);
            else
                upper_curve(i) = 0;
                lower_curve(i) = 0;
            end
        end

        hold on
        fill([t' fliplr(t')], ...
            [lower_curve' fliplr(upper_curve')], ...
            color_yarn_supply_finished, ...
            'EdgeColor', 'none', ...
            'FaceAlpha', color_alpha)
    end
end
end