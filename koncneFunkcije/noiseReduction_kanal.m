function noiseReduction_kanal = noiseReduction_kanal(image_text, image)

  img = imread(image_text);
  znanihVrednosti = 0.65;  % Probability of known values

  [n1, n2, n3] = size(img);
  n = n1;
  m = n2;
  epsilon = 1e-06;
  pixel_treshold = 4;

  % Create matrices A and M
  A = zeros(n, m, n3);
  M = ones(n, m, n3);

  % Initialize the matrices A and M
  for i = 1:n
      for j = 1:m
          % With probability znanihVrednosti, the pixel value is known
          if(rand() <= znanihVrednosti)
              #A(i, j) = img(i, j);
              #M(i, j) = 1;
          end
          for z = 1:(n3)
                %A(i + n1*z, j) = img(i, j, z + 1);
                %M(i + n1*z, j) = 1;
                A(i, j, z) = img(i, j, z);
                if (img(i,j,z) <= pixel_treshold)
                  M(i, j, z) = 0;
                endif
            end
      end
  end
  n3

  orgSlika = imread(image);

  % Run the matrix completion algorithm
  tauScalar = 50;
  deltaScalar = 1.2;
  tic
  R = svt(A(:,:,1), M(:,:,1), epsilon, 50, tauScalar, deltaScalar);
  G = svt(A(:,:,2), M(:,:,2), epsilon, 50, tauScalar, deltaScalar);
  B = svt(A(:,:,3), M(:,:,3), epsilon, 50, tauScalar, deltaScalar);

  Y = cat(3, R, G, B);

  % Reshape the 3-D matrices to 2-D before calculating the norm
  Yimg_reshaped = reshape(Y, [], size(Y, 3));
  orgSlika_reshaped = reshape(cast(orgSlika, 'double'), [], size(orgSlika, 3));
  napaka = norm(Yimg_reshaped - orgSlika_reshaped, 'fro');

  casIzvajanja = toc;

  % Display the reconstructed matrix
  Yimg = cast(Y, "uint8");

  figure;
  subplot(1, 2, 1);
  imshow(Yimg);
  title('Reconstructed Matrix (Y)');

  subplot(1, 2, 2);
  imshow(img);
  title('Original Image');

  % Print the execution time and error
  disp(['Epsilon: ', num2str(epsilon)]);
  disp(['Execution Time: ', num2str(casIzvajanja), ' seconds']);
  disp(['Reconstruction Error: ', num2str(napaka)]);
end;
