clc
clear all
close all

Data = file_loader();
DataMAX = ErrorRate_Cal();

legend_type = ["AOA0F127AC", "AOA0 AC", "AOA0 Plasma Off", ...
    "AOA5F127AC", "AOA5 AC", "AOA5 Plasma Off", ...
    "AOA9F127AC", "AOA9 AC", "AOA9 Plasma Off", ...
    "AOA10F127AC", "AOA10 AC", "AOA10 Plasma Off", ...
    "AOA12F127AC", "AOA12AC"];

for ii = 1:length(legend_type)
    p0_off = cal_fcator(Data{1, ii});
    DELTACP{1, ii} = DataMAX{1, ii};
    DELARHO = ones(1, 50) * 0.001 / 1.027;
    DELTAV = 2 * 0.1 / 5 * ones(1, 50);
    DELTAERR{1, ii} = DELTACP{1, ii};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    dpf0_off = ones(1, 50) * p0_off(1, 1) - p0_off;
    sensor_up = [18, 17, 16, 15, 14, 13, 12, 11, 10, 19, 48, 47, 46, 45, 44];
    xc_u = [0, 0.066666667, 0.1, 0.133333333, 0.166666667, 0.2, 0.266666667, 0.333333333, ...
        0.4, 0.466666667, 0.6, 0.666666667, 0.733333333, 0.8, 0.866666667, 0.933333333, 1];

    sensor_down = [8, 7, 6, 43, 42, 41, 40, 5, 4, 3, 2];
    xc_l = [0, 0.066666667, 0.133333333, 0.2, 0.333333333, 0.4, 0.466666667, 0.533333333, ...
        0.666666667, 0.733333333, 0.8, 0.866666667, 1];

    qinf = 5^2 * 0.5 * 1.027;

    cp0_off_up = dpf0_off(sensor_up + 1) / qinf;
    COR_CPu = linspace(cp0_off_up(8), cp0_off_up(11), 4);
    cp0_off_up(9:10) = COR_CPu(2:end-1);

    cp0_up{ii} = cp0_off_up;
    errCPU{ii} = DELTAERR{1, ii}(sensor_up + 1);
    cp0_off_down = dpf0_off(sensor_down + 1) / qinf;
    cp0_off_down(9:11) = interp1(xc_l(1:8), cp0_off_down(1:8), xc_l(9:11), 'nearest', 'extrap');
    cp0_down{ii} = cp0_off_down;
    errCPD{ii} = DELTAERR{1, ii}(sensor_down + 1);

end

% Error calculation:
for ii = 1:length(legend_type)
    cp0_down1{ii} = [1, cp0_down{ii}, 0];
    cp0_up1{ii} = [1, cp0_up{ii}, 0];
    errCPU1{ii} = [1, errCPU{ii}, 0];
    errCPD1{ii} = [1, errCPD{ii}, 0];

end

% Error in CL calculation:
for ii = 1:length(legend_type)
    for i = 1:length(errCPU1{ii})
        if errCPU1{ii}(i) > 0.07
            errCPU1{ii}(i) = mean(errCPU1{ii}([1:i-1, i+1:end]));
        end
    end
    for i = 1:length(errCPD1{ii})
        if errCPD1{ii}(i) > 0.07
            errCPD1{ii}(i) = mean(errCPD1{ii}([1:i-1, i+1:end]));
        end
    end
    CL(ii) = -trapz(xc_u, cp0_up1{ii}) + trapz(xc_l, cp0_down1{ii});
    % errCL(ii) = trapz(xc_u, errCPU1{ii}) + trapz(xc_l, errCPD1{ii});
end

% Plotting:
% Initialize colors and markers for each ii
colors = {'r', 'g', 'b', 'c', 'm', 'y', 'k', 'w', 'o', 's', '^', 'p', '*'};
markers = {'-d', '-*', '-o', '-s', '-^', '-p', '-h', '-+', '-x', '-v', '-<', '->', '-*'};

for ii = 1:3

    figure(1)
    title("Upper Surface Pressure Distribution AOA=12 V5 m/s")

    % Use errCPU1{ii} as error values for each point
    colorIndex = mod(ii - 1, length(colors)) + 1;
    errorbar(xc_u, cp0_up1{ii}, errCPU1{ii}, markers{ii}, 'DisplayName', 'Cp with Error', 'Color', colors{colorIndex})

    % Add data values as percentage text labels with color
    for jj = 1:length(xc_u)
        text(xc_u(jj), cp0_up1{ii}(jj) + errCPU1{ii}(jj), sprintf('%.2f%%', errCPU1{ii}(jj) * 100), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', colors{colorIndex});
    end

    xlabel("X/C")
    ylabel("Cp")
    hold on
    grid on
    legend('AC FE=127 Hz', 'AC', 'Plasmaoff');

    set(gca, 'YDir', 'reverse')

    % Add some vertical offset between datasets for better visibility
    verticalOffset = 0.02 * (ii - 13);  % Adjust the multiplier based on your preference
    ylim(get(gca, 'YLim') + verticalOffset);

    figure(2)

    title("Lower Surface Pressure Distribution AoA=12 V=5 m/s")

    % Use errCPD1{ii} as error values for each point on the lower surface
    errorbar(xc_l(2:9), cp0_down1{ii}(2:9), errCPD1{ii}(2:9), markers{ii}, 'DisplayName', 'Cp with Error', 'Color', colors{colorIndex});

    for jj = 1:length(xc_l(2:9))
        text(xc_l(jj + 1), cp0_down1{ii}(jj + 1) + errCPD1{ii}(jj + 1), sprintf('%.2f%%', errCPD1{ii}(jj + 1) * 100), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', colors{colorIndex}, 'FontSize', 8);

        % Add a vertical offset to the text labels to avoid overlap
        text(xc_l(jj + 1), cp0_down1{ii}(jj + 1) + errCPD1{ii}(jj + 1) + 0.02, '', 'Color', 'w'); % Adjust the offset as needed
    end

    xlim([0.066, 1])
    xlabel("X/C")
    ylabel("Cp")
    hold on
    grid on
    legend('AC FE=127 Hz', 'AC', 'Plasmaoff');

    set(gca, 'YDir', 'reverse')

end
for ii = 1:length(legend_type)
    CL(ii) = -trapz(xc_u, cp0_up1{ii}) + trapz(xc_l, cp0_down1{ii});
end

% Adjust CL(15) based on the given condition
CL(15) = 0.85 * CL(13);

% Reshape CL for plotting
CL_total = reshape(CL(1:15), [3, 5]).';

% Calculate errCL for each configuration
for ii = 1:length(legend_type)
    errCL(ii) = trapz(xc_u, errCPU1{ii}) + trapz(xc_l, errCPD1{ii});

end
errCL(15)= 0.85 * errCL(13);
errCL = reshape(errCL(1:15), [3, 5]).';
alpha = [0, 5, 9, 10, 12];

% Plotting lift coefficient without error bars:
% Plotting lift coefficient without error bars:
figure(3)
hBar = bar(CL_total);
legend('AC FE=127 Hz', 'AC', 'Plasma off')
title('Lift Coefficient in Angle of Attack Unsteady Excitation Effect')
xticks(1:15);
xticklabels({'AOA=0', 'AOA=5', 'AOA=9', 'AOA=10', 'AOA=12'})
grid on

% Adding text labels to the bar plot:
ytips = max(CL_total(:)) * 1.02; % Adjust the multiplier for vertical positioning
labels = string(CL_total(:));
for i = 1:numel(hBar)
    text(hBar(i).XEndPoints, hBar(i).YEndPoints + ytips, labels(i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 8);
end

% Plotting CL vs Alpha with error bars and displaying error values:
figure(4)
h1 = errorbar(alpha, CL_total(:, 3)', errCL(3:3:end), '-*', 'DisplayName', 'Plasma off');
hold on
h2 = errorbar(alpha, CL_total(:, 1)', errCL(1:3:end), '-d', 'DisplayName', 'AC');
h3 = errorbar(alpha, CL_total(:, 2)', errCL(2:3:end), '-s', 'DisplayName', 'AC FE=127 Hz');
title('CL vs Alpha V=5 m/s')
xlabel('Angle of Attack Degree')
ylabel('Lift Coefficient')
legend([h1, h2, h3], 'Location', 'Best')

% Displaying error values on data points as percentages:
for i = 1:numel(alpha)
    percentageText1 = sprintf('%.2f%%', errCL(3 + 3 * (i - 1)) * 100);
    percentageText2 = sprintf('%.2f%%', errCL(1 + 3 * (i - 1)) * 100);
    percentageText3 = sprintf('%.2f%%', errCL(2 + 3 * (i - 1)) * 100);
    
    color1 = get(h1, 'Color');
    color2 = get(h2, 'Color');
    color3 = get(h3, 'Color');
    
    text(alpha(i), CL_total(i, 3) + errCL(3 + 3 * (i - 1)) * 1.05, percentageText1, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', color1, 'FontSize', 8);
    
    text(alpha(i), CL_total(i, 1) + errCL(1 + 3 * (i - 1)) * 1.05, percentageText2, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', color2, 'FontSize', 8);
    
    text(alpha(i), CL_total(i, 2) + errCL(2 + 3 * (i - 1)) * 1.05, percentageText3, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', color3, 'FontSize', 8);
end

grid on