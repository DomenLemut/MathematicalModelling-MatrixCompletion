function noiseReduction_unknownKanal = noiseReduction_unknownKanal(image, knownValues)
  img = imread(image);
  znanihVrednosti = knownValues;  % Probability of known values

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
            for z = 1:(n3)
                A(i, j, z) = img(i, j, z);
                M(i, j, z) = 1;
            end
          end
      end
  end
  n3

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
  orgSlika_reshaped = reshape(cast(img, 'double'), [], size(img, 3));
  napaka = norm(Yimg_reshaped - orgSlika_reshaped, 'fro');
  casIzvajanja = toc;

  % Display the reconstructed matrix
  Yimg = cast(Y, "uint8");

  figure;
  subplot(1, 2, 1);
  imshow(Yimg);
  title('Reconstructed Matrix (Y)');

  subplot(1, 2, 2);
  imshow(cast(A, "uint8"));
  title('Observed Matrix');

  % Print the execution time and error
  disp(['Known values: ', num2str(znanihVrednosti), '%']);
  disp(['Epsilon: ', num2str(epsilon)]);
  disp(['Execution Time: ', num2str(casIzvajanja), ' seconds']);
  disp(['Reconstruction Error: ', num2str(napaka)]);

end;
