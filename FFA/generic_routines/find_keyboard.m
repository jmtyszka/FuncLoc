function [extKeyboard,intKeyboard] = find_keyboard

devices = PsychHID('devices');

temp_device_nums1 = [];
temp_device_nums2 = [];
for ii = 1:length(devices),
    if (strcmpi(devices(ii).manufacturer,'Current Designs, Inc.')),
        temp_device_nums1(end+1) = ii;
    end
    if (strcmpi(devices(ii).usageName,'Keyboard')),
        temp_device_nums2(end+1) = ii;
    end

end

extKeyboard = intersect(temp_device_nums1,temp_device_nums2);


%% internal mac keyboard

temp_device_nums1 = [];
temp_device_nums2 = [];
temp_device_nums3 = [];
for ii = 1:length(devices),
    if (strfind(devices(ii).manufacturer,'Apple')),
        temp_device_nums1(end+1) = ii;
    end
    if (strcmpi(devices(ii).usageName,'Keyboard')),
        temp_device_nums2(end+1) = ii;
    end
    if (strfind(devices(ii).product,'Internal')),
        temp_device_nums3(end+1) = ii;
    end

end

intKeyboard_temp = intersect(temp_device_nums1,temp_device_nums2);
intKeyboard = intersect(intKeyboard_temp,temp_device_nums3);
% intKeyboard = intKeyboard_temp;

%%

if ~exist('extKeyboard'), 
    extKeyboard = intKeyboard;
end
