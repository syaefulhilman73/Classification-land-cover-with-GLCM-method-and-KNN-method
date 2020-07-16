clear
close all
clc

load data_ciri_latih

%Mdl = fitcknn(ciri_latih, target, 'NumNeighbor', 1, 'Distance', 'euclidean');
%Mdl = fitcknn(ciri_latih, target, 'NumNeighbor', 1, 'Distance', 'cityblock');
%Mdl = fitcknn(ciri_latih, target, 'NumNeighbor', 1, 'Distance', 'minkowski');
%Mdl = fitcknn(ciri_latih, target, 'NumNeighbor', 1, 'Distance', 'chebychev');
%Mdl = fitcknn(ciri_latih, target, 'NumNeighbor', 1, 'Distance', 'cosine');
%Mdl = fitcknn(ciri_latih, target, 'NumNeighbor', 1, 'Distance', 'Correlation');
Mdl = fitcknn(ciri_latih, target, 'NumNeighbor', 5, 'Distance', 'Mahalanobis');

offset = [0 4];
level = 8;

dname = uigetdir();
isi_folder=dir(dname);
jml_uji = 0;
jml_benar = 0;

tic
for i=3:length(isi_folder)
    nama_folder=isi_folder(i).name;
    isi_file=dir([dname,'\',nama_folder,'\*.bmp']);
    for j=1:length(isi_file)
        jml_uji = jml_uji+1;
        nama_file = isi_file(j).name;
        alamat_file = [dname,'\',nama_folder,'\',nama_file];
        citra = imread(alamat_file);
         citra_resize = imresize(citra,[128 128]);
%        citra_resize = imresize(citra,[1024 1024]);
        citra_gray = rgb2gray(citra_resize);
        [glcm,SI] = graycomatrix(citra_gray,'Offset',offset,'NumLevels',level);
        stats = haralickTextureFeatures(glcm, 1:14);
        id_kelas = predict(Mdl, stats);
        kelas_uji = nama_kelas{id_kelas};
        if strcmpi(kelas_uji, nama_folder)
            jml_benar = jml_benar + 1;
        end
%         id = 1;
%         for k = 1:jml_kelas
%             plot3(ciri_latih(id:id+jml_latih_per_kelas(k)-1,1),ciri_latih(id:id+jml_latih_per_kelas(k)-1,2),...
%                 ciri_latih(id:id+jml_latih_per_kelas(k)-1,3),simbol{k});
%             id = id+jml_latih_per_kelas(k);
%             hold on
%         end
%         plot3(stats(1),stats(2),stats(3),'r*');
%         hold off
%         title('Sebaran Data');
%         xlabel('Ciri 1');
%         ylabel('Ciri 2');
%         zlabel('Ciri 3');
    end
end

waktu_komputasi = toc ./ jml_uji
akurasi = jml_benar ./ jml_uji .* 100
jml_benar
