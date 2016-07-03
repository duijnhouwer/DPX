function mergeAndSave()

warning('double check in selecting files you have the propper ones')
fnames=dpxUIgetFiles;
for f=1:numel(fnames)
    disp(fnames{f})
    data=dpxdLoad(fnames{f});
    D{f}=data;
end

data=dpxdMerge(D);

for n=2:data.N
    data.exp_subjectId{n}=data.exp_subjectId{1};
end

q=find(fnames{1}=='\');
da=datevec(date);
da=[da(1:3)];
name=[fnames{1}(q(end)+1:end-18) num2str(da) '_MERGE.mat'];
save(name,'data')


    

    
    
    
