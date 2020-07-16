clear
close all
clc

%offset = [0 1; -1 1; -1 0; -1 -1]; %arah orientasi 0, 45, 90, 135
%offset = [0 1; 0 2; 0 3; 0 4]; %jarak piksel 1, 2, 3, 4
offset = [0 4];
level = 8; % level 8, 16, 32, 64

dname = uigetdir('');
isi_folder=dir(dname);
nama_kelas=[];
ciri_latih=[];
target=[];
simbol = {'yo';'bo';'go';'mo';'co'};
jml_latih_per_kelas = zeros(length(isi_folder)-2,1);
for i=3:length(isi_folder)
    nama_folder=isi_folder(i).name;
    nama_kelas{end+1,1} = nama_folder;
    isi_file=dir([dname,'/',nama_folder,'/*.bmp']);
    jml_latih_per_kelas(i-2) = length(isi_file);
    for j=1:length(isi_file)
        nama_file = isi_file(j).name;
        alamat_file = [dname,'/',nama_folder,'/',nama_file];
        citra = imread(alamat_file);
         citra_resize = imresize(citra,[128 128]);
%         citra_resize = imresize(citra,[256 256]);
%         citra_resize = imresize(citra,[512 512]);
%        citra_resize = imresize(citra,[1024 1024]);
%         figure; imshow(citra_resize)
        citra_crop_gray = rgb2gray(citra_resize);
%        imhist(citra_crop_gray)
%         hold on;
%         figure; imshow(citra_crop_gray)
        ciri_glcm = [];
        for k = 1:size(offset,1)
            [glcm,SI] = graycomatrix(citra_crop_gray,'Offset',offset(k,:),'NumLevels',level);
            stats = haralickTextureFeatures(glcm, 1:14);
            ciri_glcm = [ciri_glcm stats];
        end
%         plot3(ciri_glcm(1),ciri_glcm(2),ciri_glcm(3),simbol{i-2});
%         title('Sebaran Data');
%         xlabel('Ciri 1');
%         ylabel('Ciri 2');
%         zlabel('Ciri 3');
%         hold on;
        ciri_latih = [ciri_latih; ciri_glcm];
        target = [target i-2];  
    end
end
jml_kelas = length(nama_kelas);
% hold off;
save data_ciri_latih ciri_latih target nama_kelas jml_latih_per_kelas jml_kelas simbol