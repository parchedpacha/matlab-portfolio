function [out] = coronastructmaker()
%coronastructmaker makes a struct with all the corona data that it can
%gather
%   Downloads the NYT database of coronavirus cases. Then organizes the
%   data into a large struct, with information for each county located in
%   separate entries. Written by Kyle Magness for ENGR112 at OSU. WARNING:
%   Will take a long time the first time its run in each 24 hr period. Then
%   will take only a short time if it can find the databse files it
%   previously downloaded and created.

%% Checking for existing saved struct
fname_struct=['coronastruct-',char(datetime('today')),'.mat'];%make filename with today's date
loadable=exist(fname_struct,'file')==2; %see if that file is there
if loadable
    fprintf('database struct found, loading...\n');
    load(fname_struct,'out');
    
else
    fprintf('Creating database struct...\n');
    %% Getting Data from NYT
    %generate filename to check for existance of downloaded database
    fname=['coronainfo-',char(datetime('today')),'.txt']; %generates a filename for any files stored today
    
    if exist(fname,'file')==2
        FID=fopen(fname,'r'); %opens the file for reading
        data=fread(FID,Inf,'*char'); %reads the file in as characters
        fclose(FID); %closes the file
        data=data';
    else
        data=webread('https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv'); %location of data
        FID=fopen(fname,'w'); %opens a new file
        fwrite(FID,data); %writes date to new file
        fclose(FID); %closes the new file
    end
    %% getting indexes for counties
    
    lines= data == newline; %get a logical array with 1 for every newline character
    numlines=sum(lines); %number of newline characters
    locationlines=zeros(1,numlines);
    x=1;
    for k=1:length(data)  %this loop gets the index for every newline
        if lines(k) %using my logical array for SPEED
            locationlines(x)=k; %if its a one, mark the current index
            x=x+1; %increment this as to avoid overwriting data
        end
    end
    loc_all_lines=[locationlines,length(lines)];
    
    
    %% looping through all entries in NYT database to allocate struct room
    out=struct;
    for k=1:(numlines-1) %this loop runs through every entry in the database
        % This next part picks through the current entry, finding the county
        % and state name, then creates a struct entry for that place if it isnt
        % in the struct yet, if it is, it adds a value to soime entries within
        
        entry=data(loc_all_lines(k)+1: loc_all_lines(k+1)-1);% gets the characters from index to next index
        comma_ind=find(entry==','); %finds the delimiter indexes
        cname=entry( comma_ind(1)+1:comma_ind(2)-1); %these 7 lines pull out important info from the string
        sname=entry( comma_ind(2)+1:comma_ind(3)-1);
        
        if diff([comma_ind(3),comma_ind(4)])==1 %if theres no room for a county code in this entry, then give it 0
            ccode='0';
        else
            ccode=entry( comma_ind(3)+1:comma_ind(4)-1);
        end
        
        % Check for special characters, store their index location for later removal.
        ind=[ find(cname==' '),find(cname=='.'),find(cname==''''),regexp( cname, '[^A-Za-z0-9]', 'start' )];
        cn2=cname;
        ind2=find(sname==' ');
        sn2=sname;
        %if special characters are found in struct entry name, remove them
        if ~isempty(ind)
            cn2(ind)='_';
        end
        if ~isempty(ind2)
            sn2(ind2)='_';
        end
        vn=[cn2,'__',sn2];
        
        %make struct values
        if ~isfield(out,vn) %if struct isnt there, make it
            out.(vn).cases=1;
            out.(vn).fatals=1;
            out.(vn).dates=1;
            out.(vn).daynum=1;
            out.(vn).num_entries=1;
            out.(vn).county_name=cname;
            out.(vn).state_name=sname;
        else %if it is there, add to it
            out.(vn).num_entries=out.(vn).num_entries+1;
        end
        if mod(k,10000)==0 %this is a progress bar because I wasn't able to make it any faster.
            fprintf('Counted %.0f / %.0f\n',k,(numlines-1));
        end
    end
    
    
    %% Making space for all the entries based on how many were found
    fprintf('Allocating space for full entries...\n');
    names=fieldnames(out); %get loist of all fieldnames (each county)
    innerfields={'cases','fatals','dates','daynum'}; %a list of the fields we want to access, so that  Idont have to run the fieldnames function a bunch of times
    for i = 1:numel(names) %iterate over that
        for j=[1,2,4] %for every data field, but not dates
            out.(names{i}).(innerfields{j})=zeros(1,out.(names{i}).num_entries); %use the value stored in that field to make a bunch of zeros for overwriting
        end
        out.(names{i}).(innerfields{3})=cell(1,out.(names{i}).num_entries);
        out.(names{i}).num_entries=0;
    end
    
    %% looping through all entries in NYT database to actually store data in the struct
    
    for k=1:(numlines-1) %this loop runs through every entry in the database
        % This next part picks through the current entry, finding where all
        % the important bits of info are located. Then stores them into
        % holding variables in preparation for struct field creation /
        % appending
        
        entry=data(loc_all_lines(k)+1: loc_all_lines(k+1)-1);% gets the characters from index to next index
        comma_ind=find(entry==','); %finds the delimiter indexes
        cname=entry( comma_ind(1)+1:comma_ind(2)-1); %these 7 lines pull out important info from the string
        sname=entry( comma_ind(2)+1:comma_ind(3)-1);
        cases=str2double(entry( comma_ind(4)+1:comma_ind(5)-1));
        fatal=str2double(entry( comma_ind(5)+1:end));
        date=entry( 1:comma_ind(1)-1);
        dateq=find(date=='-'); %split each date into days and months an years
        mo=str2double(date(dateq(1)+1:dateq(2)-1)); %months
        da=str2double(date(dateq(2)+1:end));%days
        numdays=[0,31,29,31,30,31,30,31,30,31,30,31]; %for first month, add 0 days; for feb, add all of january's days; for march, add jan +feb
        daynum= sum(numdays(1:mo))+da; %output said numbers
        
        if diff([comma_ind(3),comma_ind(4)])==1 %if theres no room for a county code in this entry, then give it 0
            ccode='0';
        else
            ccode=entry( comma_ind(3)+1:comma_ind(4)-1);
        end
        
        % Check for special characters.
        ind=[ find(cname==' '),find(cname=='.'),find(cname==''''),regexp( cname, '[^A-Za-z0-9]', 'start' )];
        cn2=cname;
        ind2=find(sname==' ');
        sn2=sname;
        %if special characters are found in struct entry name, remove them
        if ~isempty(ind)
            cn2(ind)='_';
        end
        if ~isempty(ind2)
            sn2(ind2)='_';
        end
        
        vn=[cn2,'__',sn2];
        
        %make struct values
        out.(vn).num_entries=out.(vn).num_entries+1;
        out.(vn).cases(out.(vn).num_entries)=cases;
        out.(vn).fatals(out.(vn).num_entries)=fatal;
        out.(vn).dates(out.(vn).num_entries)={date};
        out.(vn).daynum(out.(vn).num_entries)=daynum;
        
        if mod(k,10000)==0 %this is a progress bar because I wasn't able to make it any faster.
            fprintf('processed %.0f / %.0f\n',k,(numlines-1));
        end
    end
    save(fname_struct,'out');
    fprintf('ouput saved in %s\n',fname_struct);
end

fprintf('done!\n');

end

