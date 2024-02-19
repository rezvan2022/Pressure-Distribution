function  Data = file_loader()
Files = dir('*.txt');
N = size({Files.name}');

for i = 1:N(1)
    Data(i) = {dlmread(Files(i).name, '\t')};
end
m=size(Data);
for j=1:m(1,2)
    Data{1,j}=mean(Data{1,j},1);
    Data{1,j}=Data{1,j}(:,3:52);
end

end
