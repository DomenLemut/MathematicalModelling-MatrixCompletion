% Define matrix size
% n = 128;
% m = 128;
img = imread('dvobarvna.png');
znanihVrednosti = 0.65;  % Probability of known values
%img = rgb2gray(img);
if ndims(img) == 3 && size(img, 3) == 3
    img = rgb2gray(img);
end
[n1, n2] = size(img);
n = n1;
m = n2;
epsilon = 1e-06;

% Generate a random grayscale image matrix
% Mo = randi([0, 255], n, m);

% Create matrices A and M
A = zeros(n, m);
M = zeros(n, m);

% Initialize the matrices A and M
for i = 1:n
    for j = 1:m
        % With probability znanihVrednosti, the pixel value is known
        if(rand() <= znanihVrednosti)
            A(i, j) = img(i, j);
            M(i, j) = 1;
        end

    end
end

figure;
subplot(1, 2, 1);
imshow(uint8(img));
title('Original Matrix (Mo)');

subplot(1, 2, 2);
imshow(uint8(A));
title('Observed Matrix (A)');

norma = norm(cast(img, "double"), "fro");
% [n1, n2] = size(Mo);
iter = 0;
% Run the matrix completion algorithm
tic
[Y, iter] = svt(A, M, epsilon, 500);
casIzvajanja = toc;

% Calculate the reconstruction error
napaka = norm(Y - cast(img, "double"), "fro");

% Display the reconstructed matrix
Yimg = cast(Y, "uint8");

figure;
subplot(1, 2, 1);
imshow(Yimg);
title('Reconstructed Matrix (Y)');

subplot(1, 2, 2);
imshow(uint8(A));
title('Observed Matrix (A)');

% Print the execution time and error
disp(['Iterations: ', num2str(iter)]);
disp(['Unknown values: ', num2str(1 - znanihVrednosti), '%']);
disp(['Epsilon: ', num2str(epsilon)]);
disp(['Execution Time: ', num2str(casIzvajanja), ' seconds']);
disp(['Reconstruction Error: ', num2str(napaka)]);
