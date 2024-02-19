function error_rate = ErrorRate_Cal()
    Files = dir('*.txt');
    N = numel(Files);

    % Initialize error_rate cell array
    error_rate = cell(1, N);

    for i = 1:N
        % Load data from the i-th file
        Data{i} = dlmread(Files(i).name, '\t');

        % Calculate the mean and standard deviation of each column
        col_means = mean(Data{i}(:, 3:52));
        col_stdev = std(Data{i}(:, 3:52));
        % Get the number of rows in each column
        num_rows = 10000 % 

        % Divide standard deviation by the number of rows in each column
        col_stdev_normalized = col_stdev / num_rows.*col_means;
 

        % Calculate the mean of each column
        col_value= mean(Data{1,i}(:, 3:52))-mean(Data{1,i}(:, 3));
        error_rate{i} = abs(col_stdev_normalized./col_value);

    end
end

