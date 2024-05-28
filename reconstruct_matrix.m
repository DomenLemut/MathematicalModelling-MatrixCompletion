function [reconstructed_matrix, casIzvajanja, napaka] = reconstruct_matrix(img, notext, sub_size)
  % img is the input square matrix
  % notext is the original matrix without the text
  % sub_size is the size of the submatrix
  % reconstructed_matrix is the matrix obtained by averaging overlapping submatrices
  % casIzvajanja is the execution time
  % napaka is the error norm

  tic
  [n, m] = size(img);
  Observed = zeros(n, m);
  M = zeros(n, m);
  znanihVrednosti = 0.65;

  % Initialize the matrices A and M
  for i = 1:n
      for j = 1:m
          % With probability znanihVrednosti, the pixel value is known
          if(rand() <= znanihVrednosti)
              Observed(i, j) = img(i, j);
              M(i, j) = 1;
          end
          % For black text
          if (img(i,j) == 0)
            M(i, j) = 1;
          endif
          Observed(i, j) = img(i, j);
      end
  end

  % Initialize the mask matrix with zeros
  mask = zeros(n, n);

  % Initialize a cell array to store the submatrices and their corresponding masks
  submatrices = {};
  masks = {};

  % Define the step size for overlapping
  step_size = 30; % Overlapping by n elements

  % Extract overlapping submatrices and update the mask
  index = 1;
  for i = 1:step_size:(n - sub_size + 1)
    for j = 1:step_size:(n - sub_size + 1)
      submatrices{index} = Observed(i:i + sub_size - 1, j:j + sub_size - 1);
      masks{index} = M(i:i + sub_size - 1, j:j + sub_size - 1);
      mask(i:i + sub_size - 1, j:j + sub_size - 1) += 1;
      index += 1;
    end
  end

  % Initialize the reconstructed matrix with zeros
  reconstructed_matrix = zeros(n, n);
  epsilon = 1e-6;

  % SVT Loop
  % Add the submatrices back together using a for loop
  index = 1;
  for i = 1:step_size:(n - sub_size + 1)
    for j = 1:step_size:(n - sub_size + 1)
      reconstructed_matrix(i:i + sub_size - 1, j:j + sub_size - 1) += svt(submatrices{index}, masks{index}, epsilon, 500);
      index += 1;
    end
  end

  % Divide the reconstructed matrix by the mask to get the average
  reconstructed_matrix = reconstructed_matrix ./ mask;
  napaka = norm(reconstructed_matrix - cast(notext, 'double'), 'fro');

  svt_matrix = svt(Observed, M, epsilon, 500);
  svt_napaka = norm(svt_matrix - cast(notext, 'double'), 'fro');
  casIzvajanja = toc;

  figure;
  subplot(1, 2, 1);
  imshow(uint8(reconstructed_matrix));
  title('Reconstructed Matrix');

  subplot(1, 2, 2);
  imshow(uint8(Observed));
  title('Observed Matrix');

  figure;
  subplot(1, 2, 1);
  imshow(uint8(notext));
  title('Original Matrix');

  subplot(1, 2, 2);
  imshow(uint8(svt_matrix));
  title('SVT Matrix');
end
