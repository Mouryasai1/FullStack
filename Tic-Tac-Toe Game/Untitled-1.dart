
const imageUrls = ['path/to/image1.jpg', 'path/to/image2.jpg', 'path/to/image3.jpg'];
const images = [];

function loadImages() {
  const promises = [];
  for (const url of imageUrls) {
    const promise = new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => {
        images.push(img);
        resolve();
      };
      img.onerror = () => {
        reject(`Failed to load image: ${url}`);
      };
      img.src = url;
    });
    promises.push(promise);
  }
  return Promise.all(promises);
}

async function main() {
  await loadImages();

  const filters = {
    reddish: (pixelData) => pixelData[0] > pixelData[1] + pixelData[2],
    blueish: (pixelData) => pixelData[2] > pixelData[0] + pixelData[1],
    greenish: (pixelData) => pixelData[1] > pixelData[0] + pixelData[2]
  };

  let selectedFilter = null;

  // Show the images
  function showImages() {
    const container = document.getElementById('image-container');
    container.innerHTML = '';
    for (const img of images) {
      const pixelData = getPixelData(img);
      const filterFn = selectedFilter ? filters[selectedFilter] : () => true;
      if (filterFn(pixelData)) {
        const imgElem = createImgElement(img);
        container.appendChild(imgElem);
      }
    }
  }

  // Get the pixel data for an image
  function getPixelData(img) {
    const canvas = document.createElement('canvas');
    canvas.width = img.width;
    canvas.height = img.height;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(img, 0, 0);
    const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    const pixels = imageData.data;
    return [pixels[0], pixels[1], pixels[2]];
  }

  // Create an image element with the appropriate CSS classes
  function createImgElement(img) {
    const imgElem = new Image();
    imgElem.src = img.src;
    imgElem.classList.add('image');
    return imgElem;
  }

  // Create thumbnails of the images
  function createThumbnails() {
    const thumbnailSize = 100; // The size of the thumbnail image in pixels
    const container = document.getElementById('thumbnail-container');
    container.innerHTML = '';
    for (const img of images) {
      const canvas = document.createElement('canvas');
      canvas.width = thumbnailSize;
      canvas.height = thumbnailSize;
      const ctx = canvas.getContext('2d');
      ctx.drawImage(img, 0, 0, thumbnailSize, thumbnailSize);
      const thumbnailImg = new Image();
      thumbnailImg.src = canvas.toDataURL();
      thumbnailImg.classList.add('thumbnail');
      container.appendChild(thumbnailImg);
    }
  }

  // Filter the images when a filter button is clicked
  const filterButtons = document.querySelectorAll('.filter-button');
  for (const filterButton of filterButtons) {
    filterButton.addEventListener('click', () => {
      selectedFilter = filterButton.getAttribute('data-filter');
      showImages();
    });
  }

  // Show all the images when the show all button is clicked
  const showAllButton
